import Flutter
import UIKit
import HealthKit

public class AdvancedHealthKitPlugin: NSObject, FlutterPlugin {
    private let healthStore = HKHealthStore()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "advanced_health_kit", binaryMessenger: registrar.messenger())
        let instance = AdvancedHealthKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isHealthKitAvailable":
            result(HKHealthStore.isHealthDataAvailable())
            
        case "requestPermissions":
            requestPermissions(call: call, result: result)
            
        case "getHeartRate":
            getHeartRateData(call: call, result: result)
            
        case "getHRV":
            getHRVData(call: call, result: result)
            
        case "getSleepData":
            getSleepData(call: call, result: result)
            
        case "getBodyTemperature":
            getBodyTemperatureData(call: call, result: result)
            
        case "getActivityData":
            getActivityData(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let permissions = args["permissions"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid permissions", details: nil))
            return
        }
        
        var readTypes = Set<HKObjectType>()
        
        for permission in permissions {
            switch permission {
            case "heartRate":
                if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
                    readTypes.insert(heartRateType)
                }
            case "heartRateVariability":
                if let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
                    readTypes.insert(hrvType)
                }
            case "sleepAnalysis":
                if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
                    readTypes.insert(sleepType)
                }
            case "steps":
                if let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) {
                    readTypes.insert(stepsType)
                }
            case "activeEnergyBurned":
                if let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
                    readTypes.insert(energyType)
                }
            case "basalBodyTemperature":
                if let tempType = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature) {
                    readTypes.insert(tempType)
                }
            case "respiratoryRate":
                if let respType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
                    readTypes.insert(respType)
                }
            case "oxygenSaturation":
                if let oxygenType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) {
                    readTypes.insert(oxygenType)
                }
            default:
                break
            }
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
                } else {
                    result(success)
                }
            }
        }
    }
    
    private func getHeartRateData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let startTime = args["startDate"] as? Double,
              let endTime = args["endDate"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid date arguments", details: nil))
            return
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Heart rate type not available", details: nil))
            return
        }
        
        let startDate = Date(timeIntervalSince1970: startTime / 1000)
        let endDate = Date(timeIntervalSince1970: endTime / 1000)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                
                guard let heartRateSamples = samples as? [HKQuantitySample] else {
                    result([])
                    return
                }
                
                let data = heartRateSamples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())),
                        "date": sample.startDate.timeIntervalSince1970 * 1000,
                        "unit": "bpm"
                    ]
                }
                
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getHRVData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let startTime = args["startDate"] as? Double,
              let endTime = args["endDate"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid date arguments", details: nil))
            return
        }
        
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            result(FlutterError(code: "TYPE_ERROR", message: "HRV type not available", details: nil))
            return
        }
        
        let startDate = Date(timeIntervalSince1970: startTime / 1000)
        let endDate = Date(timeIntervalSince1970: endTime / 1000)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: hrvType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                
                guard let hrvSamples = samples as? [HKQuantitySample] else {
                    result([])
                    return
                }
                
                let data = hrvSamples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)),
                        "date": sample.startDate.timeIntervalSince1970 * 1000,
                        "unit": "ms"
                    ]
                }
                
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getSleepData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let startTime = args["startDate"] as? Double,
              let endTime = args["endDate"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid date arguments", details: nil))
            return
        }
        
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Sleep type not available", details: nil))
            return
        }
        
        let startDate = Date(timeIntervalSince1970: startTime / 1000)
        let endDate = Date(timeIntervalSince1970: endTime / 1000)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    result([])
                    return
                }
                
                let data = sleepSamples.map { sample in
                    var sleepStage = "unknown"
                    switch sample.value {
                    case HKCategoryValueSleepAnalysis.inBed.rawValue:
                        sleepStage = "inBed"
                    case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                        sleepStage = "asleep"
                    case HKCategoryValueSleepAnalysis.awake.rawValue:
                        sleepStage = "awake"
                    case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                        sleepStage = "core"
                    case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                        sleepStage = "deep"
                    case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                        sleepStage = "rem"
                    default:
                        break
                    }
                    
                    return [
                        "stage": sleepStage,
                        "startDate": sample.startDate.timeIntervalSince1970 * 1000,
                        "endDate": sample.endDate.timeIntervalSince1970 * 1000,
                        "duration": sample.endDate.timeIntervalSince(sample.startDate)
                    ]
                }
                
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getBodyTemperatureData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let startTime = args["startDate"] as? Double,
              let endTime = args["endDate"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid date arguments", details: nil))
            return
        }
        
        guard let tempType = HKQuantityType.quantityType(forIdentifier: .basalBodyTemperature) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Temperature type not available", details: nil))
            return
        }
        
        let startDate = Date(timeIntervalSince1970: startTime / 1000)
        let endDate = Date(timeIntervalSince1970: endTime / 1000)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: tempType,
                                 predicate: predicate,
                                 limit: HKObjectQueryNoLimit,
                                 sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                
                guard let tempSamples = samples as? [HKQuantitySample] else {
                    result([])
                    return
                }
                
                let data = tempSamples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.degreeCelsius()),
                        "date": sample.startDate.timeIntervalSince1970 * 1000,
                        "unit": "°C"
                    ]
                }
                
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getActivityData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let startTime = args["startDate"] as? Double,
              let endTime = args["endDate"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid date arguments", details: nil))
            return
        }
        
        let startDate = Date(timeIntervalSince1970: startTime / 1000)
        let endDate = Date(timeIntervalSince1970: endTime / 1000)
        
        // Get steps and active energy data
        getStepsAndEnergyData(startDate: startDate, endDate: endDate, result: result)
    }
    
    private func getStepsAndEnergyData(startDate: Date, endDate: Date, result: @escaping FlutterResult) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Activity types not available", details: nil))
            return
        }
        
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepsType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { _, results, error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
                    return
                }
                
                guard let results = results else {
                    result([])
                    return
                }
                
                var activityData: [[String: Any]] = []
                
                results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                    let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    
                    activityData.append([
                        "date": statistics.startDate.timeIntervalSince1970 * 1000,
                        "steps": steps,
                        "activeEnergy": 0.0, // We'll get this in a separate query
                        "unit": "steps"
                    ])
                }
                
                result(activityData)
            }
        }
        
        healthStore.execute(query)
    }
}
