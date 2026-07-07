import Foundation

struct Job: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var room: String
    var groutColor: String
    var sealant: String
    var rating: Int

    init(id: UUID = UUID(), date: Date = Date(), room: String, groutColor: String, sealant: String, rating: Int = 3) {
        self.id = id
        self.date = date
        self.room = room
        self.groutColor = groutColor
        self.sealant = sealant
        self.rating = rating
    }
}
