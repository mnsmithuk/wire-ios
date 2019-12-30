//
// Wire
// Copyright (C) 2019 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

extension ShareContactsViewController: PermissionDeniedViewControllerDelegate {
    public func continueWithoutPermission(_ viewController: PermissionDeniedViewController) {
        AddressBookHelper.sharedHelper.addressBookSearchWasPostponed = true
        delegate?.shareContactsViewControllerDidSkip(self)
    }
}

extension ShareContactsViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .dark)
        backgroundBlurView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(backgroundBlurView)
        backgroundBlurView.isHidden = backgroundBlurDisabled
        
        shareContactsContainerView = UIView()
        view.addSubview(shareContactsContainerView)
        
        createHeroLabel()
        createNotNowButton()
        createShareContactsButton()
        createAddressBookAccessDeniedViewController()
        createConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if AddressBookHelper.sharedHelper.isAddressBookAccessDisabled {
            displayContactsAccessDeniedMessage(animated: false)
        }
    }
    
    // MARK: - Actions
    @objc
    func shareContacts(_ sender: Any?) {
        AddressBookHelper.sharedHelper.requestPermissions({ [weak self] success in
            guard let weakSelf = self else { return }
            if success {
                AddressBookHelper.sharedHelper.startRemoteSearch( weakSelf.uploadAddressBookImmediately)
                weakSelf.delegate?.shareContactsViewControllerDidFinish(weakSelf)
            } else {
                weakSelf.displayContactsAccessDeniedMessage(animated: true)
            }
        })
    }
    
    @objc
    func shareContactsLater(_ sender: Any?) {
        AddressBookHelper.sharedHelper.addressBookSearchWasPostponed = true
        delegate?.shareContactsViewControllerDidSkip(self)
    }

    // MARK: - UIApplication notifications
    @objc
    func applicationDidBecomeActive(_ notification: Notification) {
        if AddressBookHelper.sharedHelper.isAddressBookAccessGranted {
            AddressBookHelper.sharedHelper.startRemoteSearch(true)
            delegate?.shareContactsViewControllerDidFinish(self)
        }
    }

    // MARK: - Constraints
    func createConstraints() {
        [backgroundBlurView,
         shareContactsContainerView,
         addressBookAccessDeniedViewController.view,
         heroLabel,
         shareContactsButton].forEach(){ $0.translatesAutoresizingMaskIntoConstraints = false }

        let constraints: [NSLayoutConstraint] = [shareContactsContainerView.topAnchor.constraint(equalTo: shareContactsContainerView.superview!.topAnchor),
                                                 shareContactsContainerView.bottomAnchor.constraint(equalTo: shareContactsContainerView.superview!.bottomAnchor),
                                                 shareContactsContainerView.leadingAnchor.constraint(equalTo: shareContactsContainerView.superview!.leadingAnchor),
                                                 shareContactsContainerView.trailingAnchor.constraint(equalTo: shareContactsContainerView.superview!.trailingAnchor),

                                                 backgroundBlurView.topAnchor.constraint(equalTo: backgroundBlurView.superview!.topAnchor),
                                                 backgroundBlurView.bottomAnchor.constraint(equalTo: backgroundBlurView.superview!.bottomAnchor),
                                                 backgroundBlurView.leadingAnchor.constraint(equalTo: backgroundBlurView.superview!.leadingAnchor),
                                                 backgroundBlurView.trailingAnchor.constraint(equalTo: backgroundBlurView.superview!.trailingAnchor),

                                                 addressBookAccessDeniedViewController.view.topAnchor.constraint(equalTo: addressBookAccessDeniedViewController.view.superview!.topAnchor),
                                                 addressBookAccessDeniedViewController.view.bottomAnchor.constraint(equalTo: addressBookAccessDeniedViewController.view.superview!.bottomAnchor),
                                                 addressBookAccessDeniedViewController.view.leadingAnchor.constraint(equalTo: addressBookAccessDeniedViewController.view.superview!.leadingAnchor),
                                                 addressBookAccessDeniedViewController.view.trailingAnchor.constraint(equalTo: addressBookAccessDeniedViewController.view.superview!.trailingAnchor),

                                                 heroLabel.leadingAnchor.constraint(equalTo: heroLabel.superview!.leadingAnchor, constant: 28),
                                                 heroLabel.trailingAnchor.constraint(equalTo: heroLabel.superview!.trailingAnchor, constant: -28),

                                                 shareContactsButton.topAnchor.constraint(equalTo: heroLabel.bottomAnchor, constant: 24),
                                                 shareContactsButton.heightAnchor.constraint(equalToConstant: 40),

                                                 shareContactsButton.bottomAnchor.constraint(equalTo: shareContactsButton.superview!.bottomAnchor, constant: -28),
                                                 shareContactsButton.leadingAnchor.constraint(equalTo: shareContactsButton.superview!.leadingAnchor, constant: 28),
                                                 shareContactsButton.trailingAnchor.constraint(equalTo: shareContactsButton.superview!.trailingAnchor, constant: -28)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - AddressBook Access Denied ViewController

    @objc(displayContactsAccessDeniedMessageAnimated:)
    func displayContactsAccessDeniedMessage(animated: Bool) {
        endEditing()

        showingAddressBookAccessDeniedViewController = true

        if animated {
            UIView.transition(from: shareContactsContainerView,
                              to: addressBookAccessDeniedViewController.view,
                              duration: 0.35,
                              options: [.showHideTransitionViews, .transitionCrossDissolve])
        } else {
            shareContactsContainerView.isHidden = true
            addressBookAccessDeniedViewController.view.isHidden = false
        }
    }
}


