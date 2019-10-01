//  Copyright © 2019 The Bow Authors.

import Foundation
import Bow
import BowEffects

extension Array {
    public func traverse<F: Applicative, B>(_ f: @escaping (Element) -> Kind<F, B>) -> Kind<F, [B]> {
        self.k().traverse(f).map { x in x^.asArray }
    }
    
    public func sequence<F: Applicative, A>() -> Kind<F, [A]> where Element == Kind<F, A> {
        self.traverse(id)
    }
}

extension Array where Element: Monoid {
    public func fold() -> Element {
        self.reduce(Element.empty(), Element.combine)
    }
}
