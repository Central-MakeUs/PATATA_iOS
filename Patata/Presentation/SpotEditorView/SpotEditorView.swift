//
//  SpotEditorView.swift
//  Patata
//
//  Created by 김진수 on 1/30/25.
//

import SwiftUI
import ComposableArchitecture
import Photos
import PopupView

struct SpotEditorView: View {
    
    @Perception.Bindable var store: StoreOf<SpotEditorFeature>
    
    @State private var selectedImages: [UIImage] = []
    @State private var sizeState: CGSize = .zero
    @FocusState private var focusedField: Field?
    @State private var resizedImageDatas: [Data] = []
    @State private var isImageSizeValid: Bool = false
    @State private var isResizing: Bool = false
    @State private var totalExceed: Bool = false
    @State private var invalidExceed: Bool = false
    @State private var selectedIndex: Int = 6
    
    enum Field: Hashable {
        case title
        case location
        case detail
        case hashTag
    }
    
    var body: some View {
        WithPerceptionTracking {
            if store.viewState == .add || store.viewState == .edit {
                contentView
                    .hideTabBar(true)
                    .navigationBarBackButtonHidden()
                    .background(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                            }
                    )
                    .popup(isPresented: $store.isPresentPopup.sending(\.bindingIsPresentPopup), view: {
                        HStack {
                            Spacer()
                            
                            Text(store.errorMsg)
                                .textStyle(.subtitleXS)
                                .foregroundStyle(.blue20)
                                .padding(.vertical, 10)
                            
                            Spacer()
                        }
                        .background(.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(.horizontal, 15)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                store.send(.viewEvent(.dismissPopup))
                            }
                        }
                    }, customize: {
                        $0
                            .type(.floater())
                            .position(.bottom)
                            .animation(.spring())
                            .closeOnTap(true)
                            .closeOnTapOutside(true)
                            .backgroundColor(.black.opacity(0.5))
                            .dismissCallback {
                                store.send(.viewEvent(.dismissPopup))
                            }
                        
                    })
                    .presentBottomSheet(isPresented: $store.isPresent.sending(\.bindingPresent)) {
                        BottomSheetItem(title: "카테고리 선택", items: ["스냅스팟", "시크한 야경", "일상 속 공간", "싱그러운 자연"], selectedIndex: $selectedIndex) { category in
                            store.send(.viewEvent(.tappedBottomSheet(category)))
                            store.send(.viewEvent(.closeBottomSheet(false)))
                        }
                    }
                    .customAlert(isPresented: $store.alertIsPresent.sending(\.bindingAlert), message: "태그를 제외한 나머지 스팟 정보들을 입력해주세요.\n가장 아래에 위치한 이용약관도 필수적으로 동의를 하였는지 확인해주세요.", onConfirm: {
                        store.send(.viewEvent(.dismissAlert))
                    })
                    .customAlert(
                        isPresented: $store.showPermissionAlert.sending(\.bindingPermission),
                        title: AlertMessage.imagePermission.title,
                        message: AlertMessage.imagePermission.message,
                        cancelText: AlertMessage.imagePermission.cancelTitle,
                        confirmText: AlertMessage.imagePermission.actionTitle
                    ) {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .onAppear {
                        store.send(.viewCycle(.onAppear))
                    }
            } else {
                ProgressView("파타타가 스팟을 등록하고 있습니다...")
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

extension SpotEditorView {
    private var contentView: some View {
        VStack(spacing: 0) {
            
            fakeNav
                .padding(.bottom, 14)
            
            ScrollView(.vertical) {
                titleText
                    .padding(.vertical, 28)
                    .padding(.horizontal, 15)
                
                locationView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                detailView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                categoryView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                pictureView
                    .padding(.bottom, 28)
                
                hashtagView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 50)
                
                termsView
            }
            .background(.gray20)
            .overlay(alignment: .top) {
                Color.black
                    .opacity(0.1)
                    .frame(height: 2)
                    .blur(radius: 3)
                    .offset(y: -1)
                
            }
            
            VStack {
                spotEditButton
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private var fakeNav: some View {
        ZStack {
            HStack {
                NavBackButton {
                    store.send(.viewEvent(.tappedBackButton))
                    hideKeyboard()
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text(store.viewState == .add ? "스팟 추가하기" : "스팟 수정하기")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                Spacer()
                
                Image("XActive")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 15)
                    .asButton {
                        hideKeyboard()
                        store.send(.viewEvent(.tappedXButton))
                    }
            }
        }
        
    }
    
    private var titleText: some View {
        VStack {
            HStack(spacing: 4) {
                Text("필수")
                    .textStyle(.captionS)
                    .foregroundStyle(.blue100)
                
                titleView("제목을 입력하세요")
            }
            
            textFieldView(
                bindingText: $store.title.sending(\.bindingTitle),
                placeHolder: "제목을 입력하세요 (15자 이내)",
                key: "title",
                nextFocus: .location,
                nowFocus: .title
            )
            .onChange(of: store.title) { newValue in
                store.send(.textValidation(.titleValidation(newValue)))
            }
        }
    }
    
    private var locationView: some View {
        VStack {
            titleView("상세한 위치를 입력하세요")
            
            HStack {
                Text(store.spotAddress)
                    .textStyle(.bodyS)
                    .foregroundStyle(.textDisabled)
                    .padding(.leading, 16)
                
                Spacer()
                
                Image("LocationInActive")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 18)
                    .padding(.trailing, 10)
            }
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.gray30, lineWidth: 1)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .asButton {
                store.send(.viewEvent(.tappedLocation))
            }
            
            textFieldView(
                bindingText: $store.location.sending(\.bindingLocation),
                placeHolder: "상세한 위치를 입력하세요",
                key: "location",
                nextFocus: .detail,
                nowFocus: .location
            )
            .onChange(of: store.location) { newValue in
                store.send(.textValidation(.locationValidation(newValue)))
            }
        }
    }
    
    private var detailView: some View {
        VStack {
            HStack(spacing: 4) {
                Text("필수")
                    .textStyle(.captionS)
                    .foregroundStyle(.blue100)
                
                titleView("간단한 설명을 입력하세요")
            }
            
            TextEditor(text: $store.detail.sending(\.bindingDetail))
                .textStyle(.subtitleS)
                .frame(maxWidth: .infinity)
                .aspectRatio(2.5, contentMode: .fit)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .focused($focusedField, equals: .detail)
                .onChange(of: store.detail) { newValue in
                    store.send(.textValidation(.detilValidation(newValue)))
                }
                .onSubmit {
                    focusedField = .hashTag
                }
                .overlay(
                    VStack(alignment: .leading, spacing: 16) {
                        if store.detail.isEmpty {
                            Text("장소에 대한 간단한 설명을 남겨주세요 (300자 이하)")
                                .textStyle(.bodyS)
                                .foregroundColor(.textDisabled)
                            
                            Text("부적절한 사진(폭력, 혐오, 선정성 등)은 등록이 금지되며,\n게재 시 경고 또는 이용 제한이 부과될 수 있습니다.")
                                .textStyle(.captionM)
                                .foregroundColor(.textDisabled)
                        }
                    }
                        .padding(.horizontal, 16)
                        .padding(.top, 16),
                    alignment: .topLeading
                )
        }
    }
    
    private var categoryView: some View {
        VStack {
            HStack(spacing: 4) {
                Text("필수")
                    .textStyle(.captionS)
                    .foregroundStyle(.blue100)
                
                titleView("카테고리를 선택해주세요")
            }
            
            HStack {
                Text(store.categoryText)
                    .textStyle(store.categoryText == "카테고리를 선택해주세요" ? .bodyS : .subtitleS)
                    .foregroundColor(store.categoryText == "카테고리를 선택해주세요" ? .textDisabled : .textSub)
                    .padding(.leading, 16)
                    .onChange(of: store.categoryText) { newValue in
                        store.send(.textValidation(.categoryValidtaion(newValue)))
                    }
                
                Spacer()
                
                Image("UnderIcon")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 18)
                    .padding(.trailing, 10)
            }
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .asButton {
                hideKeyboard()
                store.send(.viewEvent(.openBottomSheet(true)))
            }
        }
    }
    
    @ViewBuilder
    private var pictureView: some View {
        VStack {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text("필수")
                        .textStyle(.captionS)
                        .foregroundStyle(store.viewState == .add ? .blue100 : .textInfo)
                        .padding(.leading, 15)
                    
                    HStack {
                        Text("사진을 추가해주세요")
                            .textStyle(.subtitleM)
                            .foregroundStyle(store.viewState == .add ? .textDefault : .textDisabled)
                        
                        Spacer()
                    }
                }
                
                HStack {
                    Text("이미지는 최대 3장까지 업로드 가능하며, 스팟 등록 이후 수정이 불가합니다.")
                        .textStyle(.captionS)
                        .foregroundStyle(.textDisabled)
                        .padding(.leading, 15)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(.bottom, 4)
            
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if store.viewState == .add {
                            PhotoPickerView(
                                selectedImages: $selectedImages,
                                showPermissionAlert: $store.showPermissionAlert.sending(\.bindingPermission),
                                isImageSizeValid: $isImageSizeValid,
                                resizedImageDatas: $resizedImageDatas,
                                isResizing: $isResizing,
                                invalidExceed: $invalidExceed,
                                totalExceed: $totalExceed
                            ) {
                                VStack(alignment: .center) {
                                    Image("ImageDefault")
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(width: 36)
                                    
                                    Text("사진 추가하기")
                                        .textStyle(.captionS)
                                        .foregroundStyle(.gray60)
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 20)
                                .sizeState(size: $sizeState)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.gray30, lineWidth: 1)
                                        .background(.gray20)
                                )
                            }
                            .padding(.leading, 15)
                            
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: sizeState.width, height: sizeState.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(alignment: .bottom) {
                                            if index == 0 {
                                                HStack {
                                                    Spacer()
                                                    
                                                    Text("대표 이미지")
                                                        .textStyle(.captionS)
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 7)
                                                        .padding(.horizontal, 8)
                                                    
                                                    Spacer()
                                                }
                                                .background(.blue100)
                                                .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                                            }
                                        }
                                    
                                    if !isResizing {
                                        Image("WhiteX")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 34, height: 34)
                                            .onTapGesture {
                                                selectedImages.remove(at: index)
                                                if index < resizedImageDatas.count {
                                                    resizedImageDatas.remove(at: index)
                                                }
                                            }
                                    }
                                }
                            }
                        } else {
                            ScrollView(.horizontal) {
                                HStack(spacing: 4) {
                                    Spacer()
                                        .frame(width: 11)
                                    
                                    ForEach(Array(store.imageURLs.enumerated()), id: \.offset) { index, url in
                                        let imageWidth: CGFloat = UIScreen.main.bounds.width - 30
                                        
                                        DownImageView(url: url, option: .mid, fallBackImg: "ImageDefault")
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: (imageWidth - 8) / 2.5)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .clipped()
                                            .overlay(alignment: .bottom) {
                                                if index == 0 {
                                                    HStack {
                                                        Spacer()
                                                        
                                                        Text("대표 이미지")
                                                            .textStyle(.captionS)
                                                            .foregroundColor(.white)
                                                            .padding(.vertical, 7)
                                                            .padding(.horizontal, 8)
                                                        
                                                        Spacer()
                                                    }
                                                    .background(.blue100)
                                                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 0)
                            }
                        }
                    }
                }
                
                if isResizing {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.gray60)
                            Text("이미지 리사이징 중...")
                                .textStyle(.captionS)
                                .foregroundStyle(.gray60)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray20.opacity(0.8))
                }
            }
            
            if invalidExceed {
                HStack {
                    Text("*이미지 장 당 최대 용량은 5mb입니다. 용량을 확인해주세요!")
                        .textStyle(.captionS)
                        .foregroundStyle(.red100)
                    
                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.top, 4)

            }
            
            
            if totalExceed {
                HStack {
                    Text("*이미지 총 용량은 10mb를 넘지 않도록 해주세요.")
                        .textStyle(.captionS)
                        .foregroundStyle(.red100)
                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.top, 4)

            }
            
        }
    }
    
    private var hashtagView: some View {
        VStack {
            titleView("해쉬태그를 입력해주세요 (최대 2개)")
            
            textFieldView(
                bindingText: $store.hashTag.sending(\.bindingHashTag),
                placeHolder: "#해쉬태그를 입력해주세요", key: "hashTag",
                nextFocus: .hashTag,
                nowFocus: .hashTag,
                customOnSubmit: {
                    store.send(.viewEvent(.hashTagOnSubmit))
                }
            )
            .disabled(store.hashTags.count == 2)
            .onChange(of: store.hashTag) { newValue in
                store.send(.textValidation(.hashTagValidation(newValue)))
            }
            
            HStack {
                ForEach(Array(store.hashTags.enumerated()), id: \.element.self) { index, item in
                    HStack(spacing: 4) {
                        Text(item)
                            .textStyle(.captionS)
                            .foregroundStyle(.gray80)
                        
                        Image("XInActive")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .asButton {
                                store.send(.viewEvent(.deleteHashTag(index)))
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .strokeBorder(.gray30, lineWidth: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    )
                }
                
                Spacer()
            }
            .padding(.top, 4)
            
        }
    }
    
    private var termsView: some View {
        VStack(spacing: 12) {
            Divider()
            
            Toggle(isOn: $store.agreeToTerms.sending(\.bindingAgreeToTerms)) {
                HStack(spacing: 4) {
                    Text("필수")
                        .textStyle(.captionS)
                        .foregroundStyle(store.viewState == .add ? .blue100 : .textInfo)
                    
                    Text("이용약관 및 커뮤니티 가이드라인에 동의")
                        .textStyle(.subtitleS)
                        .foregroundStyle(.textDefault)
                }
            }
            .padding(.horizontal, 15)
            
            Text("부적절한 콘텐츠나 악의적인 사용자로 신고될 경우 계정 이용이 제한될 수 있습니다, 24시간 이내에 검토 후 삭제처리가 될 수 있습니다..")
                .textStyle(.captionS)
                .foregroundStyle(.textDisabled)
                .padding(.horizontal, 15)
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 28)
    }
    
    private var spotEditButton: some View {
        HStack {
            Spacer()
            
            Text(store.viewState == .add ? "등록하기" : "수정하기")
                .textStyle(.subtitleM)
                .foregroundStyle(.white)
                
            Spacer()
        }
        .padding(.vertical, 14)
        .background(store.viewState == .add ? (store.spotEditorIsValid && !selectedImages.isEmpty ? .black : .gray50) : (store.spotEditorIsValid ? .black : .gray50))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .asButton {
            if store.spotEditorIsValid {
                if store.viewState == .add && !selectedImages.isEmpty {
                    store.send(.viewEvent(.tappedSpotAddButton(resizedImageDatas)))
                } else {
                    store.send(.viewEvent(.tappedSpotEditButton))
                }
            } else {
                store.send(.viewEvent(.openAlert))
            }
        }
        .disabled(isResizing)
        .opacity(isResizing ? 0.5 : 1.0)
    }
}

extension SpotEditorView {
    private func textFieldView(bindingText: Binding<String>, placeHolder: String, key: String, nextFocus: Field, nowFocus: Field, customOnSubmit: (() -> Void)? = nil) -> some View {
        DisablePasteTextField(
            text: bindingText,
            isFocused: nil,
            placeholder: placeHolder,
            placeholderColor: .textDisabled,
            edge: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0),
            keyboardType: .default,
            onCommit: {
                if let customOnSubmit = customOnSubmit {
                    customOnSubmit()
                } else {
                    focusedField = nextFocus
                }
            }
        )
        .textStyle(.subtitleS)
        .focused($focusedField, equals: nowFocus)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func titleView(_ text: String) -> some View {
        HStack {
            Text(text)
                .textStyle(.subtitleM)
                .foregroundStyle(.textDefault)
            
            Spacer()
        }
    }
}
