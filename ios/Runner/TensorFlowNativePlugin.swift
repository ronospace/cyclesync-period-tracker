import Foundation
import TensorFlowLite
import CoreML
import Accelerate

/// Native iOS TensorFlow Lite + Core ML bridge for CycleSync AI predictions
/// Phase 2 implementation for on-device machine learning
@objc(TensorFlowNativePlugin)
class TensorFlowNativePlugin: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    private var loadedInterpreters: [String: Interpreter] = [:]
    private var modelMetadata: [String: ModelMetadata] = [:]
    private var isInitialized = false
    
    // MARK: - Plugin Registration
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cyclesync/tensorflow", binaryMessenger: registrar.messenger())
        let instance = TensorFlowNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // MARK: - Method Channel Handler
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadModel":
            handleLoadModel(call: call, result: result)
        case "runInference":
            handleRunInference(call: call, result: result)
        case "getModelInfo":
            handleGetModelInfo(call: call, result: result)
        case "unloadModel":
            handleUnloadModel(call: call, result: result)
        case "unloadAllModels":
            handleUnloadAllModels(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Model Loading
    private func handleLoadModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let modelName = args["modelName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Model name is required", details: nil))
            return
        }
        
        let useGPU = args["useGPU"] as? Bool ?? false
        let numThreads = args["numThreads"] as? Int ?? 2
        
        // Check if model is already loaded
        if loadedInterpreters[modelName] != nil {
            result(["success": true, "message": "Model already loaded", "cached": true])
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let interpreter = try self?.loadTensorFlowLiteModel(
                    modelName: modelName,
                    useGPU: useGPU,
                    numThreads: numThreads
                )
                
                guard let interpreter = interpreter else {
                    throw TensorFlowError.modelLoadFailed("Failed to create interpreter")
                }
                
                // Store the interpreter
                DispatchQueue.main.async {
                    self?.loadedInterpreters[modelName] = interpreter
                    self?.modelMetadata[modelName] = ModelMetadata(
                        name: modelName,
                        loadedAt: Date(),
                        useGPU: useGPU,
                        numThreads: numThreads
                    )
                    result(["success": true, "message": "Model loaded successfully"])
                }
                
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = "Failed to load model \(modelName): \(error.localizedDescription)"
                    print("🚨 \(errorMessage)")
                    result(FlutterError(code: "MODEL_LOAD_ERROR", message: errorMessage, details: nil))
                }
            }
        }
    }
    
    private func loadTensorFlowLiteModel(modelName: String, useGPU: Bool, numThreads: Int) throws -> Interpreter {
        // Get the model file path from the app bundle
        guard let modelPath = Bundle.main.path(forResource: modelName, ofType: nil) else {
            throw TensorFlowError.modelNotFound("Model file not found: \(modelName)")
        }
        
        // Configure TensorFlow Lite options
        var options = Interpreter.Options()
        options.threadCount = numThreads
        
        // Configure delegates
        if useGPU {
            // Try to use GPU delegate for better performance
            do {
                let gpuDelegate = MetalDelegate()
                options.addDelegate(gpuDelegate)
                print("✅ GPU acceleration enabled for \(modelName)")
            } catch {
                print("⚠️ GPU delegate not available, falling back to CPU for \(modelName)")
            }
        }
        
        // Try Core ML delegate as fallback for better iOS performance
        do {
            let coreMLDelegate = CoreMLDelegate()
            options.addDelegate(coreMLDelegate)
            print("✅ Core ML acceleration enabled for \(modelName)")
        } catch {
            print("⚠️ Core ML delegate not available for \(modelName)")
        }
        
        // Create and initialize the interpreter
        let interpreter = try Interpreter(modelPath: modelPath, options: options)
        try interpreter.allocateTensors()
        
        print("🧠 Successfully loaded TensorFlow Lite model: \(modelName)")
        return interpreter
    }
    
    // MARK: - Inference
    private func handleRunInference(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let modelName = args["modelName"] as? String,
              let inputDataArray = args["inputData"] as? [Double],
              let outputShape = args["outputShape"] as? [Int] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid inference arguments", details: nil))
            return
        }
        
        guard let interpreter = loadedInterpreters[modelName] else {
            result(FlutterError(code: "MODEL_NOT_LOADED", message: "Model \(modelName) is not loaded", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let output = try self?.runInference(
                    interpreter: interpreter,
                    inputData: inputDataArray,
                    outputShape: outputShape
                )
                
                DispatchQueue.main.async {
                    result([
                        "success": true,
                        "output": output ?? [],
                        "inference_time_ms": Date().timeIntervalSince(Date()) * 1000,
                        "model_name": modelName
                    ])
                }
                
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = "Inference failed for \(modelName): \(error.localizedDescription)"
                    print("🚨 \(errorMessage)")
                    result(FlutterError(code: "INFERENCE_ERROR", message: errorMessage, details: nil))
                }
            }
        }
    }
    
    private func runInference(interpreter: Interpreter, inputData: [Double], outputShape: [Int]) throws -> [Double] {
        let startTime = Date()
        
        // Convert input data to Float32 tensor
        let inputTensor = try interpreter.input(at: 0)
        let inputFloats = inputData.map { Float32($0) }
        let inputData = Data(bytes: inputFloats, count: inputFloats.count * MemoryLayout<Float32>.stride)
        
        try interpreter.copy(inputData, toInputAt: 0)
        
        // Run inference
        try interpreter.invoke()
        
        // Get output tensor
        let outputTensor = try interpreter.output(at: 0)
        let outputData = outputTensor.data
        
        // Convert output data back to Double array
        let outputFloats = outputData.withUnsafeBytes { bytes in
            Array(bytes.bindMemory(to: Float32.self))
        }
        
        let outputDoubles = outputFloats.map { Double($0) }
        
        let inferenceTime = Date().timeIntervalSince(startTime) * 1000
        print("⚡ Inference completed in \(String(format: "%.2f", inferenceTime))ms")
        
        return outputDoubles
    }
    
    // MARK: - Model Information
    private func handleGetModelInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let modelName = args["modelName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Model name is required", details: nil))
            return
        }
        
        guard let metadata = modelMetadata[modelName],
              let interpreter = loadedInterpreters[modelName] else {
            result(FlutterError(code: "MODEL_NOT_LOADED", message: "Model \(modelName) is not loaded", details: nil))
            return
        }
        
        do {
            // Get input tensor info
            let inputTensor = try interpreter.input(at: 0)
            let inputShape = inputTensor.shape.dimensions
            
            // Get output tensor info
            let outputTensor = try interpreter.output(at: 0)
            let outputShape = outputTensor.shape.dimensions
            
            let modelInfo: [String: Any] = [
                "model_name": metadata.name,
                "loaded_at": ISO8601DateFormatter().string(from: metadata.loadedAt),
                "uses_gpu": metadata.useGPU,
                "thread_count": metadata.numThreads,
                "input_shape": inputShape,
                "output_shape": outputShape,
                "input_dtype": tensorTypeToString(inputTensor.dataType),
                "output_dtype": tensorTypeToString(outputTensor.dataType)
            ]
            
            result(modelInfo)
            
        } catch {
            result(FlutterError(code: "MODEL_INFO_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func tensorTypeToString(_ type: TensorDataType) -> String {
        switch type {
        case .float32:
            return "float32"
        case .int32:
            return "int32"
        case .uInt8:
            return "uint8"
        case .int64:
            return "int64"
        case .string:
            return "string"
        case .bool:
            return "bool"
        case .int16:
            return "int16"
        case .complex64:
            return "complex64"
        case .int8:
            return "int8"
        case .float16:
            return "float16"
        case .float64:
            return "float64"
        @unknown default:
            return "unknown"
        }
    }
    
    // MARK: - Model Unloading
    private func handleUnloadModel(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let modelName = args["modelName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Model name is required", details: nil))
            return
        }
        
        loadedInterpreters.removeValue(forKey: modelName)
        modelMetadata.removeValue(forKey: modelName)
        
        print("🗑️ Unloaded model: \(modelName)")
        result(["success": true, "message": "Model unloaded successfully"])
    }
    
    private func handleUnloadAllModels(result: @escaping FlutterResult) {
        let modelCount = loadedInterpreters.count
        loadedInterpreters.removeAll()
        modelMetadata.removeAll()
        
        print("🗑️ Unloaded \(modelCount) models")
        result(["success": true, "message": "All models unloaded successfully", "count": modelCount])
    }
}

// MARK: - Supporting Types
struct ModelMetadata {
    let name: String
    let loadedAt: Date
    let useGPU: Bool
    let numThreads: Int
}

enum TensorFlowError: Error, LocalizedError {
    case modelNotFound(String)
    case modelLoadFailed(String)
    case invalidInputData(String)
    case inferenceFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound(let message),
             .modelLoadFailed(let message),
             .invalidInputData(let message),
             .inferenceFailed(let message):
            return message
        }
    }
}

// MARK: - Core ML Delegate Extension
extension CoreMLDelegate {
    convenience init() throws {
        var settings = CoreMLDelegate.Settings()
        settings.enabledDevices = .all
        settings.coreMLVersion = 3
        try self.init(settings: settings)
    }
}

// MARK: - Performance Optimizations
extension TensorFlowNativePlugin {
    
    /// Preload commonly used models for better performance
    func preloadEssentialModels() {
        let essentialModels = [
            "ovulation_predictor_v2.tflite",
            "hrv_stress_analyzer_v3.tflite"
        ]
        
        for modelName in essentialModels {
            DispatchQueue.global(qos: .background).async { [weak self] in
                do {
                    let interpreter = try self?.loadTensorFlowLiteModel(
                        modelName: modelName,
                        useGPU: true,
                        numThreads: 4
                    )
                    
                    if let interpreter = interpreter {
                        DispatchQueue.main.async {
                            self?.loadedInterpreters[modelName] = interpreter
                            self?.modelMetadata[modelName] = ModelMetadata(
                                name: modelName,
                                loadedAt: Date(),
                                useGPU: true,
                                numThreads: 4
                            )
                            print("🚀 Preloaded essential model: \(modelName)")
                        }
                    }
                    
                } catch {
                    print("⚠️ Failed to preload \(modelName): \(error)")
                }
            }
        }
    }
    
    /// Optimize memory usage by unloading least recently used models
    func optimizeMemoryUsage() {
        let maxModels = 3
        
        if loadedInterpreters.count > maxModels {
            // Sort models by load time and unload oldest
            let sortedModels = modelMetadata.sorted { $0.value.loadedAt < $1.value.loadedAt }
            let modelsToUnload = sortedModels.prefix(loadedInterpreters.count - maxModels)
            
            for (modelName, _) in modelsToUnload {
                loadedInterpreters.removeValue(forKey: modelName)
                modelMetadata.removeValue(forKey: modelName)
                print("🧹 Unloaded LRU model: \(modelName)")
            }
        }
    }
}

// MARK: - Health Data Processing Extensions
extension TensorFlowNativePlugin {
    
    /// Normalize health data for better model performance
    func normalizeHealthData(_ data: [Double], type: HealthDataType) -> [Double] {
        switch type {
        case .heartRate:
            // Normalize heart rate to 0-1 range (assuming 40-200 BPM)
            return data.map { max(0, min(1, ($0 - 40) / 160)) }
        case .hrv:
            // Normalize HRV to 0-1 range (assuming 0-100 ms)
            return data.map { max(0, min(1, $0 / 100)) }
        case .temperature:
            // Normalize temperature to 0-1 range (assuming 96-102°F)
            return data.map { max(0, min(1, ($0 - 96) / 6)) }
        case .sleepScore:
            // Sleep scores are already 0-100, normalize to 0-1
            return data.map { max(0, min(1, $0 / 100)) }
        case .steps:
            // Normalize steps to 0-1 range (assuming 0-30000 steps)
            return data.map { max(0, min(1, $0 / 30000)) }
        case .cycleDay:
            // Normalize cycle day to 0-1 range (assuming 1-40 days)
            return data.map { max(0, min(1, ($0 - 1) / 39)) }
        }
    }
    
    enum HealthDataType {
        case heartRate
        case hrv
        case temperature
        case sleepScore
        case steps
        case cycleDay
    }
}
