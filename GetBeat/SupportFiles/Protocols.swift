
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

protocol VKLoginProtocol {
    func setupAfterLogin(state: Bool, user: VKUser, isEmailLogin: Bool)
    func setupElements(state: Bool)
}

enum PickerEnum: Int {
    case mood
    case genre
    case key
    case license
}
