//
//  FilterCellEnum.swift
//  Stats
//
//  Created by Leonid Kibukevich on 06.10.2021.
//

import Foundation

enum FilterCellType {
    case usual(data: CategoryValueFilterViewModel)
    case closable(data: CategoryValueFilterViewModel)
    case button(title: String)
}
