
import Foundation
#if os(Linux)
    import Glibc
#endif

enum FileError: ErrorType {
    case WriteError
}

struct MultipartFile {
    
    let name: String
    
    let data: [UInt8]
    
    func saveToTemporaryDirectory(filename: String, completion: ((path: String?, error: ErrorType?) -> Void)) {
        
        #if os(Linux)
            let path = "/var/tmp"
        #else
            let path = NSTemporaryDirectory() + "\(filename)"
        #endif
    
        saveToPath(path, completion: completion)
    }
    
    func saveToPath(path: String, completion: ((path: String?, error: ErrorType?) -> Void)) {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let raw = NSData(bytesNoCopy: UnsafeMutablePointer<Void>(self.data),
                length: self.data.count * sizeof(UInt8), freeWhenDone: false)
            
            if raw.writeToFile(path, atomically: true) {
                
                completion(path: path, error: nil)
                
            } else {
                
                completion(path: nil, error: FileError.WriteError)
            }
        }
    }
    
}