import ContextKitCore
import Foundation

struct MenuSectionProvider {
    func sections(for descriptors: [MenuDescriptor]) -> [(ActionCategory, [MenuDescriptor])] {
        ActionCategory.allCases.compactMap { category in
            let matches = descriptors
                .filter { $0.category == category }
                .sorted(by: { $0.sortOrder < $1.sortOrder })
            guard !matches.isEmpty else {
                return nil
            }
            return (category, matches)
        }
    }
}
