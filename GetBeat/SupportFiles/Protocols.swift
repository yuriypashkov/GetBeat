
import Foundation

protocol PickerDelegate {
    func pickerValueSelected(value: String, picker: PickerEnum, valueIndex: Int)
}

protocol FilterDelegate {
    func filterValuesSelected(filterDictionary: [String: String?])
}

protocol HotTracksPageControllerDelegate: class {
    func setCurrentPage(index: Int)
    func setNumberOfPages(numberOfPages: Int)
    //func setCurrentTrack(track: Track)
}

enum PickerEnum: Int {
    case mood
    case genre
    case key
    case license
}
