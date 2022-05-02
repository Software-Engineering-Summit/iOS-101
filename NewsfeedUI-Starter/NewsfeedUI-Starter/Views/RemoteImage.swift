//
//  RemoteImage.swift
//  NewsfeedUI
//
//  Created by Levine, Merlin on 04/29/22.
//

import SwiftUI

/// SwiftUI helper `View` to load remote images.
struct RemoteImage: View {
    private var urlString: String
    private var mockRequest: Bool

    @ViewBuilder
    var body: some View {
        if mockRequest {
            Image("image\(Int.random(in: 1...13))").resizable()
        } else {
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo").resizable()
                case .success(let image):
                    image.resizable()
                case .failure:
                    Image(systemName: "multiply.circle").resizable()
                @unknown default:
                    Image(systemName: "exclamationmark.icloud").resizable()
                }
            }
        }
    }

    init(url: String?, mockRequest: Bool = Constants.useMockResponses) {
        self.urlString = url ?? ""
        self.mockRequest = mockRequest
    }
}
