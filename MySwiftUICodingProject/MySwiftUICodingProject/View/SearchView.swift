//
//  SearchView.swift
//  MySwiftUICodingProject
//
//  Created by wheat on 1/25/26.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""

    private let items = ["One", "Two", "Three", "Four", "Five"]

    private var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        }

        return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredItems, id: \.self) { item in
                    Text(item)
            }
            .navigationTitle("Search")
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    SearchView()
}

/**
 VStack(spacing: 0) {
     Image(systemName: "magnifyingglass")
         .font(.system(size: 100))

     Text("Search")
         .font(Font.largeTitle)
 }
 .foregroundStyle(Color.gray.opacity(0.5))
 */
