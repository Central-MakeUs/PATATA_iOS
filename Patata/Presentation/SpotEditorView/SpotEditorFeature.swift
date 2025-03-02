//
//  SpotEditorFeature.swift
//  Patata
//
//  Created by 김진수 on 1/30/25.
//

import Foundation
import ComposableArchitecture
import UIKit

// 처음 들어올때 스팟을 등록하러 왔는지 수정하러 왔는지 체크 필요 이건 처음에 모든 값이 들어오는지로 판단해야될듯
@Reducer
struct SpotEditorFeature {
    
    @ObservableState
    struct State: Equatable {
        var viewState: ViewState
        var spotDetail: SpotDetailEntity
        var initViewState: ViewState = .add
        var spotLocation: Coordinate
        var spotAddress: String
        var spotEditorIsValid: Bool = false
        var categoryText: String = "카테고리를 선택해주세요"
        var imageURLs: [URL?] = []
        var hashTags: [String] = []
        var imageDatas: [Data]
        var selectedImages: [UIImage] = []
        var errorMsg: String = ""
        var isFirst: Bool = true
        let beforeViewState: BeforeViewState
        var agreeToTerms: Bool = false
        var alertIsPresent: Bool = false
        var deleteIndex: Int? = nil
        
        // bindingState
        var title: String = ""
        var location: String = ""
        var detail: String = ""
        var hashTag: String = ""
        var isPresent: Bool = false
        var showPermissionAlert: Bool = false
        var isPresentPopup: Bool = false
    }
    
    enum ViewState {
        case add
        case edit
        case loading
    }
    
    enum BeforeViewState {
        case map
        case searchMap
        case other
    }
    
    enum Action {
        case textValidation(TextValidation)
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case errorHandle(ErrorHandleType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedBackButton
            case successSpotAdd
            case tappedXButton
            case tappedLocation(Coordinate, ViewState, SpotDetailEntity, [Data])
            case changeAddress(Coordinate, String)
            case successSpotEdit(BeforeViewState)
        }
        
        // bindingAction
        case bindingTitle(String)
        case bindingLocation(String)
        case bindingDetail(String)
        case bindingHashTag(String)
        case bindingPresent(Bool)
        case bindingPermission(Bool)
        case bindingIsPresentPopup(Bool)
        case bindingAgreeToTerms(Bool)
        case bindingAlert(Bool)
        case bindingImageData([Data])
        case bindingImage([UIImage])
        case bindingDeleteIndex(Int?)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum TextValidation {
        case titleValidation(String)
        case locationValidation(String)
        case categoryValidtaion(String)
        case detilValidation(String)
        case hashTagValidation(String)
    }
    
    enum ViewEvent {
        case tappedBottomSheet(String)
        case tappedBackButton
        case openBottomSheet(Bool)
        case closeBottomSheet(Bool)
        case hashTagOnSubmit
        case deleteHashTag(Int)
        case tappedSpotAddButton
        case dismissPopup
        case tappedXButton
        case tappedLocation
        case tappedSpotEditButton
        case openAlert
        case dismissAlert
        case deleteImage(Int)
    }
    
    enum NetworkType {
        case createSpot
        case spotEdit
    }
    
    enum ErrorHandleType {
        case imageResize(Error)
        case networkFail(Error)
    }
    
    enum DataTransType {
        case checkViewState
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotEditorFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.initViewState = state.viewState
                
                return .send(.dataTransType(.checkViewState))
                
            case let .viewEvent(.tappedBottomSheet(category)):
                state.categoryText = category
                
            case let .viewEvent(.openBottomSheet(isPresent)):
                state.isPresent = isPresent
                
            case let .viewEvent(.closeBottomSheet(isPresent)):
                state.isPresent = isPresent
                
            case .viewEvent(.hashTagOnSubmit):
                let tagToAdd = state.hashTag.hasPrefix("#") ? String(state.hashTag.dropFirst()) : state.hashTag
                
                if !tagToAdd.isEmpty {
                    state.hashTags.append(tagToAdd)
                    state.hashTag = ""
                }
                
                validateEditorState(&state)
                
            case let .viewEvent(.deleteHashTag(index)):
                state.hashTags.remove(at: index)
                
                validateEditorState(&state)
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.dismissPopup):
                state.isPresentPopup = false
                
            case .viewEvent(.tappedSpotAddButton):
                return .run { send in
                    await send(.networkType(.createSpot))
                }
                
            case .viewEvent(.tappedSpotEditButton):
                return .run { send in
                    await send(.networkType(.spotEdit))
                }
                
            case .viewEvent(.tappedXButton):
                return .send(.delegate(.tappedXButton))
                
            case .viewEvent(.tappedLocation):
                let viewState = state.viewState
                let coord = state.spotLocation
                let spotDetail = SpotDetailEntity(spotId: 0, isAuthor: false, spotAddress: "", spotAddressDetail: state.location, spotName: state.title, spotDescription: state.detail, categoryId: CategoryCase(rawValue: CategoryCase.getCategoryId(text: state.categoryText)) ?? .all, memberName: "", images: state.imageURLs, reviewCount: 0, isScraped: false, tags: state.hashTags, reviews: [], spotCoord: Coordinate(latitude: 0, longitude: 0), memberId: nil)
                
                return .send(.delegate(.tappedLocation(coord, viewState, spotDetail, state.imageDatas)))
                
            case let .viewEvent(.deleteImage(index)):
                if index < state.selectedImages.count && index < state.imageDatas.count {
                    state.imageDatas.remove(at: index)
                    state.selectedImages.remove(at: index)
                }
                
                state.deleteIndex = nil
                state.deleteIndex = index
                
            case .viewEvent(.openAlert):
                state.alertIsPresent = true
                
            case .viewEvent(.dismissAlert):
                state.alertIsPresent = false
                
            case let .delegate(.changeAddress(spotCoord, address)):
                state.isFirst = false
                state.spotLocation = spotCoord
                state.spotAddress = address
                
            case .dataTransType(.checkViewState):
                if state.viewState == .edit && state.isFirst {
                    state.isFirst = false
                    state.title = state.spotDetail.spotName
                    state.spotAddress = state.spotDetail.spotAddress
                    state.location = state.spotDetail.spotAddressDetail
                    state.detail = state.spotDetail.spotDescription
                    state.hashTags = state.spotDetail.tags
                    state.imageURLs = state.spotDetail.images
                    state.categoryText = state.spotDetail.categoryId.getCategoryCase().title
                    state.spotLocation = state.spotDetail.spotCoord
                } else if state.viewState == .add && state.isFirst {
                    state.isFirst = false
                    state.title = state.spotDetail.spotName
                    state.location = state.spotDetail.spotAddressDetail
                    state.detail = state.spotDetail.spotDescription
                    state.hashTags = state.spotDetail.tags
                    state.categoryText = state.spotDetail.categoryId.getCategoryCase().title
                    
                    if !state.imageDatas.isEmpty {
                        state.imageDatas.forEach { data in
                            if let image = UIImage(data: data) {
                                state.selectedImages.append(image)
                            }
                        }
                    }
                }
                
            case .networkType(.createSpot):
                let categoryId = CategoryCase.getCategoryId(text: state.categoryText)
                state.viewState = .loading
                
                let spotName = state.title
                let spotAddress = state.spotAddress
                let spotAddressDetail = state.location
                let coord = state.spotLocation
                let spotDes = state.detail
                let tag = state.hashTags
                let image = state.imageDatas
                
                return .run { send in
                    do {
                        try await spotRepository.createSpot(spotName: spotName, spotAddress: spotAddress, spotAddressDetail: spotAddressDetail, coord: coord, spotDescription: spotDes, categoryId: categoryId, tags: tag, images: image)
                        
                        await send(.delegate(.successSpotAdd))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                        await send(.errorHandle(.networkFail(error)))
                    }
                }
                
            case .networkType(.spotEdit):
                let title = state.title
                let address = state.spotAddress
                let addressDetail = state.location
                let spotDetail = state.detail
                let category = CategoryCase.getCategoryId(text: state.categoryText)
                let hashTag = state.hashTags
                let spotId = state.spotDetail.spotId
                let spotCoord = state.spotLocation
                
                let before = state.beforeViewState
                
                return .run { send in
                    do {
                        let result = try await spotRepository.spotEdit(title: title, spotAddress: address, spotAddressDetail: addressDetail, spotLocation: spotCoord, spotDetail: spotDetail, spotCategory: CategoryCase(rawValue: category) ?? .houseSpot, hashTag: hashTag, spotId: spotId)
                        
                        if result {
                            await send(.delegate(.successSpotEdit(before)))
                        }
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .errorHandle(.imageResize(error)):
                state.errorMsg = errorManager.handleError(error) ?? ""
                state.isPresentPopup = true
                
            case let .errorHandle(.networkFail(error)):
                state.viewState = state.initViewState
                state.errorMsg = errorManager.handleError(error) ?? ""
                state.isPresentPopup = true
                
            case let .textValidation(.titleValidation(titleText)):
                let limitedText = String(titleText.prefix(15))

                if limitedText.first == " " {
                    state.title = ""
                    return .none
                }

                if limitedText.contains("  ") {
                    state.title = limitedText.replacingOccurrences(of: "  ", with: " ")
                    validateEditorState(&state)
                    return .none
                }

                if let lastChar = state.title.last,
                   lastChar == " ",
                   limitedText.last == " " {
                    state.title = state.title
                    validateEditorState(&state)
                    return .none
                }

                var allowedCharacters = CharacterSet()
                allowedCharacters.formUnion(.alphanumerics)
                allowedCharacters.formUnion(.whitespaces)
                allowedCharacters.insert(charactersIn: "가-힣")

                // 문자열을 Unicode.Scalar로 변환하여 필터링
                let filteredText = limitedText.unicodeScalars.filter {
                    allowedCharacters.contains($0)
                }.reduce(into: "") { result, scalar in
                    result.append(String(scalar))
                }

                state.title = filteredText
                validateEditorState(&state)
                
            case let .textValidation(.locationValidation(locationText)):
                var allowedCharacters = CharacterSet()
                allowedCharacters.formUnion(.alphanumerics)
                allowedCharacters.formUnion(.whitespaces)
                allowedCharacters.insert(charactersIn: "가-힣")
                allowedCharacters.insert(charactersIn: "-")

                let filteredText = locationText.unicodeScalars.filter {
                    allowedCharacters.contains($0)
                }.reduce(into: "") { result, scalar in
                    result.append(String(scalar))
                }

                state.location = filteredText
                validateEditorState(&state)
                
            case let .textValidation(.detilValidation(detail)):
                let totalLength = detail.reduce(0) { count, char in
                    if char == "\n" {
                        return count + 1
                    }
                    return count + 1
                }
                
                if totalLength > 300 {
                    state.detail = state.detail
                    return .none
                }
                
                if detail.contains("  ") {
                    state.detail = state.detail
                    return .none
                }
                
                if detail.first == " " {
                    state.detail = ""
                    return .none
                }
                    
                state.detail = detail
                
                validateEditorState(&state)
                
            case let .textValidation(.categoryValidtaion(category)):
                if category == "카테고리를 선택해주세요" {
                    return .none
                }
                
                validateEditorState(&state)
                
            case let .textValidation(.hashTagValidation(text)):
                var processedText = text

                if !text.hasPrefix("#") {
                    processedText = "#" + text
                }

                let withoutHash = processedText.dropFirst()

                let withoutExtraHash = withoutHash.replacingOccurrences(of: "#", with: "")

                let specialCharPattern = "[^a-zA-Z0-9가-힣\\s]"
                let filteredText = withoutExtraHash.components(separatedBy: CharacterSet(charactersIn: specialCharPattern))
                    .joined()

                let singleSpaceText = filteredText.replacingOccurrences(
                    of: "\\s+",
                    with: " ",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces)

                let limitedText = String(singleSpaceText.prefix(5))

                state.hashTag = text.isEmpty ? "" : "#" + limitedText

                
            case let .bindingTitle(titleText):
                state.title = titleText
                
            case let .bindingLocation(locationText):
                state.location = locationText

            case let .bindingDetail(detail):
                state.detail = detail
                
            case let .bindingHashTag(hashTag):
                state.hashTag = hashTag
                
            case let .bindingPresent(isPresent):
                state.isPresent = isPresent
                
            case let .bindingPermission(permission):
                state.showPermissionAlert = permission
                
            case let .bindingIsPresentPopup(isPresent):
                state.isPresentPopup = isPresent
                
            case let .bindingAgreeToTerms(isAgree):
                state.agreeToTerms = isAgree
                validateEditorState(&state)
                
            case let .bindingAlert(isPresent):
                state.alertIsPresent = isPresent
                
            case let .bindingImageData(data):
                state.imageDatas = data
                
            case let .bindingImage(image):
                state.selectedImages = image
                
            case let .bindingDeleteIndex(index):
                state.deleteIndex = index
                
            default:
                break
            }
            
            return .none
        }
    }
    
    private func validateEditorState(_ state: inout State) {
        print("check", state.title,
              state.detail,
              state.categoryText,
              state.agreeToTerms)
        state.spotEditorIsValid = !state.title.isEmpty &&
        !state.detail.isEmpty && state.detail.count <= 300 &&
                                     state.categoryText != "카테고리를 선택해주세요" &&
                                     state.agreeToTerms
    }
}
