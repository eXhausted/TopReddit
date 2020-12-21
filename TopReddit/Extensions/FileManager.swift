import Foundation

extension FileManager {
    
    var libraryFolderURL: URL {
        FileManager
            .default
            .urls(for: .libraryDirectory, in: .userDomainMask)
            .first!
    }
    
    var imagesFolderURL: URL { libraryFolderURL.appendingPathComponent("Images") }
    var filesFolderURL: URL { libraryFolderURL.appendingPathComponent("Files") }
    var stateFileURL: URL { filesFolderURL.appendingPathComponent("State.json") }
    
    func prepare() {
        createFolderIfNeeded(path: imagesFolderURL.path)
        createFolderIfNeeded(path: filesFolderURL.path)
    }
    
    func createFolderIfNeeded(path: String) {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if !exists {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
