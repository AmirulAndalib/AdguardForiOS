//
// This file is part of Adguard for iOS (https://github.com/AdguardTeam/AdguardForiOS).
// Copyright © Adguard Software Limited. All rights reserved.
//
// Adguard for iOS is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Adguard for iOS is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Adguard for iOS. If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

/// Informs the user that iOS 27 Connectivity Assist may bypass DNS filtering and how to turn it off.
/// The title and the button title come from the storyboard, the summary is set here because it
/// contains HTML markup that has to be rendered through an attributed string.
final class ConnectivityAssistWarningController: BottomAlertController {

    @IBOutlet weak var titleLabel: ThemableLabel!
    @IBOutlet weak var descriptionLabel: ThemableLabel!
    @IBOutlet weak var gotItButton: UIButton!

    @IBOutlet var themableLabels: [ThemableLabel]!

    // MARK: - services

    private let theme: ThemeServiceProtocol = ServiceLocator.shared.getService()!

    override func viewDidLoad() {
        super.viewDidLoad()

        gotItButton.applyStandardGreenStyle()
        updateTheme()
    }

    // MARK: - Actions

    @IBAction func gotItTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Private methods

    private func setupDescription() {
        let summary = String.localizedString("connectivity_assist_warning_summary")
        descriptionLabel.setAttributedTitle(
            summary,
            fontSize: descriptionLabel.font.pointSize,
            color: theme.grayTextColor,
            textAlignment: .center
        )
    }
}

extension ConnectivityAssistWarningController: ThemableProtocol {
    func updateTheme() {
        titleLabel.textColor = theme.popupTitleTextColor
        contentView.backgroundColor = theme.popupBackgroundColor
        theme.setupLabels(themableLabels)

        descriptionLabel.font = .systemFont(ofSize: isIpadTrait ? 20.0 : 17.0)

        setupDescription()
    }
}
