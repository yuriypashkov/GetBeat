
import Foundation

protocol PickerDelegate {
    func pickerValueSelected(value: String, buttonTag: Int, valueIndex: Int)
}

protocol FilterDelegate {
    func filterValuesSelected(filterDictionary: [String: String?])
}
