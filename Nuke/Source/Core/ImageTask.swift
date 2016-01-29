// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

import Foundation

public enum ImageTaskState {
    case Suspended, Running, Cancelled, Completed
}

public typealias ImageTaskCompletion = (ImageResponse) -> Void

public struct ImageTaskProgress {
    public var completed: Int64 = 0
    public var total: Int64 = 0
    public var fractionCompleted: Double {
        return self.total == 0 ? 0.0 : Double(self.completed) / Double(self.total)
    }
}

/** Abstract class for image tasks. Tasks are always part of the image manager, you create a task by calling one of the methods on ImageManager.
 */
public class ImageTask: Hashable {
    /** The request that task was created with.
     */
    public let request: ImageRequest
    
    /** The current state of the task.
     */
    public internal(set) var state: ImageTaskState = .Suspended
    public internal(set) var response: ImageResponse?
    public internal(set) var progress = ImageTaskProgress()
    public var hashValue: Int { return self.identifier }
    
    /** Uniquely identifies the task within an image manager.
     */
    public let identifier: Int
    
    /** A progress closure that gets periodically during the lifecycle of the task.
     */
    public var progressHandler: ((progress: ImageTaskProgress) -> Void)?
    
    public init(request: ImageRequest, identifier: Int) {
        self.request = request
        self.identifier = identifier
    }
    
    /** Adds a closure to be called on the main thread when task is either completed or cancelled.
     
     The closure is called synchronously when the requested image can be retrieved from the memory cache and the request was made from the main thread.
     
     The closure is called even if it is added to the already completed or cancelled task.
     */
    public func completion(completion: ImageTaskCompletion) -> Self { fatalError("Abstract method") }
    
    /** Resumes the task if suspended. Resume and suspend methods are nestable.
     */
    public func resume() -> Self { fatalError("Abstract method") }
    
    /** Advices the task to suspend loading. If the task is suspended if might still complete at any time.
     
     A download task can continue transferring data at a later time. All other tasks must start over when resumed. For more info on suspending NSURLSessionTask see NSURLSession documentation.
     */
    public func suspend() -> Self { fatalError("Abstract method") }
    
    /** Cancels the task if it hasn't completed yet. Calls a completion closure with an error value of { ImageManagerErrorDomain, ImageManagerErrorCancelled }.
     */
    public func cancel() -> Self { fatalError("Abstract method") }
}

public func ==(lhs: ImageTask, rhs: ImageTask) -> Bool {
    return lhs === rhs
}
