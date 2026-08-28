import Foundation

enum MealPhotoStore {
    private static var directory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MealPhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func save(imageData: Data) -> String? {
        let fileName = "\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(fileName)
        do {
            try imageData.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    static func load(fileName: String) -> Data? {
        try? Data(contentsOf: directory.appendingPathComponent(fileName))
    }

    static func delete(fileName: String) {
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(fileName))
    }
}
