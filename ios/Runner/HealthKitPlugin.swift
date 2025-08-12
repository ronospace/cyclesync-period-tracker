import Flutter
import UIKit
import HealthKit

public class HealthKitPlugin: NSObject, FlutterPlugin {
    private let healthStore = HKHealthStore()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cyclesync/healthkit", binaryMessenger: registrar.messenger())
        let instance = HealthKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            requestHealthKitPermissions(result: result)
        case "getHeartRateData":
            getHeartRateData(result: result)
        case "getHRVData":
            getHRVData(result: result)
        case "getSleepData":
            getSleepData(result: result)
        case "getBodyTemperatureData":
            getBodyTemperatureData(result: result)
        case "getActivityData":
            getActivityData(result: result)
        case "getRespiratoryRateData":
            getRespiratoryRateData(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func requestHealthKitPermissions(result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: "UNAVAILABLE", message: "HealthKit not available", details: nil))
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!,
            HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if success {
                    result(["success": true, "message": "HealthKit permissions granted"])
                } else {
                    result(FlutterError(code: "PERMISSION_DENIED", 
                                      message: error?.localizedDescription ?? "Permission denied", 
                                      details: nil))
                }
            }
        }
    }
    
    private func getHeartRateData(result: @escaping FlutterResult) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Heart rate type not available", details: nil))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    result(FlutterError(code: "QUERY_ERROR", message: error?.localizedDescription ?? "Query failed", details: nil))
                    return
                }
                
                let data = samples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())),
                        "date": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                        "source": sample.sourceRevision.source.name
                    ]
                }
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getHRVData(result: @escaping FlutterResult) {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            result(FlutterError(code: "TYPE_ERROR", message: "HRV type not available", details: nil))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    result(FlutterError(code: "QUERY_ERROR", message: error?.localizedDescription ?? "Query failed", details: nil))
                    return
                }
                
                let data = samples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)),
                        "date": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                        "source": sample.sourceRevision.source.name
                    ]
                }
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getSleepData(result: @escaping FlutterResult) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Sleep type not available", details: nil))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    result(FlutterError(code: "QUERY_ERROR", message: error?.localizedDescription ?? "Query failed", details: nil))
                    return
                }
                
                let data = samples.map { sample in
                    let sleepStage: String
                    if #available(iOS 16.0, *) {
                        switch sample.value {
                        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                            sleepStage = "deep"
                        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                            sleepStage = "rem"
                        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                            sleepStage = "light"
                        case HKCategoryValueSleepAnalysis.awake.rawValue:
                            sleepStage = "awake"
                        default:
                            sleepStage = "unknown"
                        }
                    } else {
                        switch sample.value {
                        case HKCategoryValueSleepAnalysis.asleep.rawValue:
                            sleepStage = "asleep"
                        case HKCategoryValueSleepAnalysis.awake.rawValue:
                            sleepStage = "awake"
                        default:
                            sleepStage = "unknown"
                        }
                    }
                    
                    return [
                        "stage": sleepStage,
                        "startDate": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                        "endDate": Int64(sample.endDate.timeIntervalSince1970 * 1000),
                        "source": sample.sourceRevision.source.name
                    ]
                }
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getBodyTemperatureData(result: @escaping FlutterResult) {
        guard let tempType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Body temperature type not available", details: nil))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: tempType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    result(FlutterError(code: "QUERY_ERROR", message: error?.localizedDescription ?? "Query failed", details: nil))
                    return
                }
                
                let data = samples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.degreeFahrenheit()),
                        "date": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                        "source": sample.sourceRevision.source.name
                    ]
                }
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func getActivityData(result: @escaping FlutterResult) {
        let group = DispatchGroup()
        var activityData: [String: Any] = [:]
        var errors: [Error] = []
        
        // Get step count
        group.enter()
        getStepCount { stepResult, error in
            if let error = error {
                errors.append(error)
            } else {
                activityData["steps"] = stepResult
            }
            group.leave()
        }
        
        // Get active energy
        group.enter()
        getActiveEnergy { energyResult, error in
            if let error = error {
                errors.append(error)
            } else {
                activityData["activeEnergy"] = energyResult
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                result(FlutterError(code: "QUERY_ERROR", message: "Failed to fetch activity data", details: errors.first?.localizedDescription))
            } else {
                result(activityData)
            }
        }
    }
    
    private func getStepCount(completion: @escaping ([Any]?, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(nil, error)
                return
            }
            
            let data = samples.map { sample in
                return [
                    "value": sample.quantity.doubleValue(for: HKUnit.count()),
                    "date": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                    "source": sample.sourceRevision.source.name
                ]
            }
            completion(data, nil)
        }
        
        healthStore.execute(query)
    }
    
    private func getActiveEnergy(completion: @escaping ([Any]?, Error?) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Active energy type not available"]))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: energyType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(nil, error)
                return
            }
            
            let data = samples.map { sample in
                return [
                    "value": sample.quantity.doubleValue(for: HKUnit.kilocalorie()),
                    "date": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                    "source": sample.sourceRevision.source.name
                ]
            }
            completion(data, nil)
        }
        
        healthStore.execute(query)
    }
    
    private func getRespiratoryRateData(result: @escaping FlutterResult) {
        guard let respiratoryType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            result(FlutterError(code: "TYPE_ERROR", message: "Respiratory rate type not available", details: nil))
            return
        }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: respiratoryType, predicate: predicate, limit: 100, sortDescriptors: nil) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    result(FlutterError(code: "QUERY_ERROR", message: error?.localizedDescription ?? "Query failed", details: nil))
                    return
                }
                
                let data = samples.map { sample in
                    return [
                        "value": sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())),
                        "date": Int64(sample.startDate.timeIntervalSince1970 * 1000),
                        "source": sample.sourceRevision.source.name
                    ]
                }
                result(data)
            }
        }
        
        healthStore.execute(query)
    }
}
