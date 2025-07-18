//
//  DownImageView.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import SwiftUI
import Kingfisher

struct DownImageView: View {
    
    let url: URL?
    let option: Option
    var fallbackURL: URL? = nil
    var fallBackImg: String? = nil
    
    enum Option {
        case max
        case mid
        case min
        case custom(CGSize)
        
        var size: CGSize {
            return switch self {
            case .max:
                CGSize(width: 500, height: 500)
            case .mid:
                CGSize(width: 300, height: 300)
            case .min:
                CGSize(width: 100, height: 100)
            case let .custom(size):
                size
            }
        }
    }
    
    var body: some View {
        KFImage(url)
            .setProcessor(
                DownsamplingImageProcessor(
                    size: option.size
                )
            )
            .placeholder {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                Group {
//                    if let fallBackImg {
//                        Image(fallBackImg)
//                            .resizable()
//                            .saturation(0)
//                    } else {
//                        KFImage(fallbackURL)
//                            .resizable()
//                    }
//                }
            }
            .onFailure { error in
#if DEBUG
                print(error)
#endif
            }
            .loadDiskFileSynchronously(false) // 동기적 디스크 호출 안함
            .cancelOnDisappear(true) // 사라지면 취소
            .diskCacheExpiration(.days(7))  // 7일 후 디스크 캐시에서 만료
            .backgroundDecode(true) // 백그라운드에서 디코딩
            .processingQueue(.dispatch(DispatchQueue.global(qos: .userInitiated)))
            .retry(maxCount: 2, interval: .seconds(1))
            .resizable()
    }
}
