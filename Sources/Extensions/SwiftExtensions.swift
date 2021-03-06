//
// SwiftExtensions.swift
//
// Copyright © 2014 Zeeshan Mian
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public extension String {
    /// Allows us to use String[index] notation
    public subscript(index: Int) -> String? {
        let array = Array(characters)
        return array.indices ~= index ? String(array[index]) : nil
    }

    /// var string = "abcde"[0...2] // string equals "abc"
    /// var string2 = "fghij"[2..<4] // string2 equals "hi"
    public subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end   = startIndex.advancedBy(r.endIndex)
        return substringWithRange(Range(start..<end))
    }

    public var count: Int { return characters.count }

    /// Returns an array of strings at new lines.
    public var lines: [String] {
        return componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }

    /// Trims white space and new line characters in `self`.
    @warn_unused_result
    public func trim() -> String {
        return replace("[ ]+", replacement: " ").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }

    /// Searches for pattern matches in the string and replaces them with replacement.
    @warn_unused_result
    public func replace(pattern: String, replacement: String, options: NSStringCompareOptions = .RegularExpressionSearch) -> String {
        return stringByReplacingOccurrencesOfString(pattern, withString: replacement, options: options, range: nil)
    }

    /// Returns `true` iff `value` is in `self`.
    @warn_unused_result
    public func contains(value: String, options: NSStringCompareOptions = []) -> Bool {
        return rangeOfString(value, options: options) != nil
    }

    /// Determine whether the string is a valid url.
    public var isValidUrl: Bool {
        if let url = NSURL(string: self) where url.host != nil {
            return true
        }

        return false
    }

    /// `true` iff `self` contains no characters and blank spaces (e.g., \n, " ").
    public var isBlank: Bool {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty
    }

    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }

    public func localized(comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }

    /// Drops the given `prefix` from `self`.
    ///
    /// - returns: String without the specified `prefix` or nil if `prefix` doesn't exists.
    @warn_unused_result
    public func stripPrefix(prefix: String) -> String? {
        guard let prefixRange = rangeOfString(prefix) else { return nil }
        let attributeRange  = Range(prefixRange.endIndex..<endIndex)
        let attributeString = substringWithRange(attributeRange)
        return attributeString
    }

    public var lastPathComponent: String { return (self as NSString).lastPathComponent }
    public var stringByDeletingLastPathComponent: String { return (self as NSString).stringByDeletingLastPathComponent }
    public var stringByDeletingPathExtension: String { return (self as NSString).stringByDeletingPathExtension }
    public var pathExtension: String { return (self as NSString).pathExtension }

    /// Decode specified `Base64` string
    public init?(base64: String) {
        if let decodedData   = NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions(rawValue: 0)),
           let decodedString = String(data: decodedData, encoding: NSUTF8StringEncoding) {
            self = decodedString
        } else {
            return nil
        }
    }

    /// Returns `Base64` representation of `self`.
    public var base64: String? {
        return dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}

public extension String {
    @warn_unused_result
    public func sizeWithFont(font: UIFont) -> CGSize {
        return (self as NSString).sizeWithAttributes([NSFontAttributeName: font])
    }

    @warn_unused_result
    public func sizeWithFont(font: UIFont, constrainedToSize: CGSize) -> CGSize {
        let expectedRect = (self as NSString).boundingRectWithSize(constrainedToSize, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return expectedRect.size
    }

    /// - seealso: http://stackoverflow.com/a/30040937
    @warn_unused_result
    public func numberOfLines(font: UIFont, constrainedToSize: CGSize) -> (size: CGSize, numberOfLines: Int) {
        let textStorage = NSTextStorage(string: self, attributes: [NSFontAttributeName: font])

        let textContainer                  = NSTextContainer(size: constrainedToSize)
        textContainer.lineBreakMode        = .ByWordWrapping
        textContainer.maximumNumberOfLines = 0
        textContainer.lineFragmentPadding  = 0

        let layoutManager = NSLayoutManager()
        layoutManager.textStorage = textStorage
        layoutManager.addTextContainer(textContainer)

        var numberOfLines = 0
        var index         = 0
        var lineRange     = NSRange(location: 0, length: 0)
        var size          = CGSize.zero

        while index < layoutManager.numberOfGlyphs {
            numberOfLines += 1
            size += layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange).size
            index = NSMaxRange(lineRange)
        }

        return (size, numberOfLines)
    }
}

public extension Int {
    @warn_unused_result
    public func padding(amountToPad: Int) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.paddingPosition = .BeforePrefix
        numberFormatter.paddingCharacter = "0"
        numberFormatter.minimumIntegerDigits = amountToPad
        return numberFormatter.stringFromNumber(self)!
    }
}

extension IntervalType {
    /// Returns a random element from `self`.
    ///
    /// ```
    /// (0.0...1.0).random()   // 0.112358
    /// (-1.0..<68.5).random() // 26.42
    /// ```
    @warn_unused_result
    public func random() -> Bound {
        guard
            let start = self.start as? Double,
            let end = self.end as? Double
        else {
            return self.start
        }

        let range = end - start
        return ((Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)) * range + start) as! Bound
    }
}

extension Int {
    /// Returns an `Array` containing the results of mapping `transform`
    /// over `self`.
    ///
    /// - complexity: O(N).
    ///
    /// ```
    /// let values = 10.map { $0 * 2 }
    /// print(values)
    ///
    /// // prints
    /// [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
    /// ```
    @warn_unused_result
    public func map<T>(@noescape transform: (Int) throws -> T) rethrows -> [T] {
        var results = [T]()
        for i in 0..<self {
            try results.append(transform(i + 1))
        }
        return results
    }
}

extension Array {
    /// Returns a random subarray of given length
    ///
    /// - parameter size: Length
    /// - returns:        Random subarray of length n
    @warn_unused_result
    public func randomElements(size: Int = 1) -> Array {
        if size >= count {
            return self
        }

        let index = Int(arc4random_uniform(UInt32(count - size)))
        return Array(self[index..<(size + index)])
    }

    /// Returns a random element from `self`.
    @warn_unused_result
    public func randomElement() -> Element {
        let randomIndex = Int(rand()) % count
        return self[randomIndex]
    }

    /// Split array by chunks of given size.
    ///
    /// ```
    /// let arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    /// let chunks = arr.splitBy(5)
    /// print(chunks) // [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12]]
    /// ```
    /// - seealso: https://gist.github.com/ericdke/fa262bdece59ff786fcb
    public func splitBy(subSize: Int) -> [[Element]] {
        return 0.stride(to: count, by: subSize).map { startIndex in
            let endIndex = startIndex.advancedBy(subSize, limit: count)
            return Array(self[startIndex..<endIndex])
        }
    }
}

public extension Array where Element: Equatable {
    /// Remove element by value.
    ///
    /// - returns: true if removed; false otherwise
    public mutating func remove(element: Element) -> Bool {
        for (index, elementToCompare) in enumerate() {
            if element == elementToCompare {
                removeAtIndex(index)
                return true
            }
        }
        return false
    }

    /// Remove elements by value.
    public mutating func remove(elements: [Element]) {
        elements.forEach { remove($0) }
    }

    /// Move an element in `self` to a specific index.
    ///
    /// - parameter element: The element in `self` to move.
    /// - parameter toIndex: An index locating the new location of the element in `self`.
    ///
    /// - returns: true if moved; false otherwise.
    public mutating func move(element: Element, toIndex index: Int) -> Bool {
        guard remove(element) else { return false }
        insert(element, atIndex: index)
        return true
    }
}

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    @warn_unused_result
    public func at(index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CollectionType where Index: BidirectionalIndexType {
    /// Returns the `SubSequence` at the specified range iff it is within bounds, otherwise nil.
    @warn_unused_result
    public func at(range: Range<Index>) -> SubSequence? {
        return indices.contains(range) ? self[range] : nil
    }

    /// Return true iff range is in `self`.
    @warn_unused_result
    public func contains(range: Range<Index>) -> Bool {
        return indices.contains(range.startIndex) && indices.contains(range.endIndex.predecessor())
    }
}

extension RangeReplaceableCollectionType {
    public mutating func appendAll(collection: [Generator.Element]) {
        appendContentsOf(collection)
    }
}

extension SequenceType where Generator.Element: Hashable {
    /// Return an `Array` containing only the unique elements of `self` in order.
    @warn_unused_result
    public func unique() -> [Generator.Element] {
        var seen: [Generator.Element: Bool] = [:]
        return filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension SequenceType {
    /// Return an `Array` containing only the unique elements of `self`,
    /// in order, where `unique` criteria is determined by the `uniqueProperty` block.
    ///
    /// - parameter uniqueProperty: `unique` criteria is determined by the value returned by this block.
    ///
    /// - returns: Return an `Array` containing only the unique elements of `self`,
    /// in order, that satisfy the predicate `uniqueProperty`.
    @warn_unused_result
    public func unique<T: Hashable>(uniqueProperty: (Generator.Element) -> T) -> [Generator.Element] {
        var seen: [T: Bool] = [:]
        return filter { seen.updateValue(true, forKey: uniqueProperty($0)) == nil }
    }
}

public extension Array where Element: Hashable {
    /// Modify `self` in-place such that only the unique elements of `self` in order are remaining.
    public mutating func uniqueInPlace() {
        self = unique()
    }

    /// Modify `self` in-place such that only the unique elements of `self` in order are remaining,
    /// where `unique` criteria is determined by the `uniqueProperty` block.
    ///
    /// - parameter uniqueProperty: `unique` criteria is determined by the value returned by this block.
    public mutating func uniqueInPlace<T: Hashable>(uniqueProperty: (Element) -> T) {
        self = unique(uniqueProperty)
    }
}

public extension Dictionary {
    public mutating func unionInPlace(dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    @warn_unused_result
    public func union(dictionary: Dictionary) -> Dictionary {
        var dictionary = dictionary
        dictionary.unionInPlace(self)
        return dictionary
    }
}

extension Double {
    // Adopted from: http://stackoverflow.com/a/35504720

    private static let abbrevationNumberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.allowsFloats = true
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter
    }()
    private typealias Abbrevation = (suffix: String, threshold: Double, divisor: Double)
    private static let abbreviations: [Abbrevation] = [
                                       ("",                0,              1),
                                       ("K",           1_000,          1_000),
                                       ("K",         100_000,          1_000),
                                       ("M",         499_000,      1_000_000),
                                       ("M",     999_999_999,     10_000_000),
                                       ("B",   1_000_000_000,  1_000_000_000),
                                       ("B", 999_999_999_999, 10_000_000_000)]

    /// Abbreviate `self` to smaller format.
    ///
    /// ```
    /// 987     // -> 987
    /// 1200    // -> 1.2K
    /// 12000   // -> 12K
    /// 120000  // -> 120K
    /// 1200000 // -> 1.2M
    /// 1340    // -> 1.3K
    /// 132456  // -> 132.5K
    /// ```
    /// - returns: Abbreviated version of `self`.
    @warn_unused_result
    public func abbreviate() -> String {
        let startValue = abs(self)

        let abbreviation: Abbrevation = {
            var prevAbbreviation = Double.abbreviations[0]

            for tmpAbbreviation in Double.abbreviations {
                if startValue < tmpAbbreviation.threshold {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        }()

        let value = self / abbreviation.divisor
        Double.abbrevationNumberFormatter.positiveSuffix = abbreviation.suffix
        Double.abbrevationNumberFormatter.negativeSuffix = abbreviation.suffix
        return Double.abbrevationNumberFormatter.stringFromNumber(value) ?? "\(self)"
    }

    private static let testValues: [Double] = [598, -999, 1000, -1284, 9940, 9980, 39900, 99880, 399880, 999898, 999999, 1456384, 12383474, 987, 1200, 12000, 120000, 1200000, 1340, 132456, 9_000_000_000, 16_000_000, 160_000_000, 999_000_000]
}

extension SequenceType where Generator.Element == Double {
    /// ```
    /// [1, 1, 1, 1, 1, 1].runningSum() // -> [1, 2, 3, 4, 5, 6]
    /// ```
    @warn_unused_result
    public func runningSum() -> [Generator.Element] {
        return self.reduce([]) { sums, element in
            return sums + [element + (sums.last ?? 0)]
        }
    }
}
