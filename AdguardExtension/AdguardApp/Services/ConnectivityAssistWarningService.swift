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

import Foundation

protocol ConnectivityAssistWarningServiceProtocol {
    /// Returns `true` when the Connectivity Assist warning dialog is allowed to be presented.
    var shouldShowDialog: Bool { get }

    /// Returns `true` when the Connectivity Assist warning badge is allowed to be shown.
    var shouldShowBadge: Bool { get }

    /// Persists the fact that the dialog has been shown, so it is never presented again.
    func markDialogAsShown()

    /// Persists the fact that the badge has been closed by the user, so it is never shown again.
    func markBadgeAsShown()
}

/// Decides whether the Connectivity Assist warning dialog may be shown and stores the shown state.
///
/// The dialog warns that on iOS 27 the system Connectivity Assist feature can send DNS requests
/// over cellular data, bypassing AdGuard filtering. It is relevant only for the AdGuard DNS
/// implementation, because the native one is not affected by the fallback resolver path.
final class ConnectivityAssistWarningService: ConnectivityAssistWarningServiceProtocol {

    private let resources: AESharedResourcesProtocol
    private let complexProtection: ComplexProtectionServiceProtocol
    init(
        resources: AESharedResourcesProtocol,
        complexProtection: ComplexProtectionServiceProtocol
    ) {
        self.resources = resources
        self.complexProtection = complexProtection
    }

    var shouldShowDialog: Bool {
        // The Connectivity Assist fallback resolver exists starting from iOS 27 only
        guard #available(iOS 27.0, *) else {
            DDLogInfo("(ConnectivityAssistWarningService) - dialog is not shown, iOS version is lower than 27")
            return false
        }

        // The dialog explains DNS filtering gaps, which the native implementation does not have
        guard resources.dnsImplementation == .adGuard else {
            DDLogInfo("(ConnectivityAssistWarningService) - dialog is not shown, DNS implementation is not AdGuard")
            return false
        }

        // The system protection can be enabled by Pro users only,
        // see ComplexProtectionService.systemProtectionEnabled
        guard complexProtection.systemProtectionEnabled else {
            DDLogInfo("(ConnectivityAssistWarningService) - dialog is not shown, system protection is disabled")
            return false
        }

        // Connectivity Assist bypasses the tunnel only in the split mode
        guard resources.tunnelMode == .split else {
            DDLogInfo("(ConnectivityAssistWarningService) - dialog is not shown, tunnel mode is not split")
            return false
        }

        guard !resources.connectivityAssistDialogShown else {
            DDLogInfo("(ConnectivityAssistWarningService) - dialog is not shown, it has already been shown")
            return false
        }

        DDLogInfo("(ConnectivityAssistWarningService) - dialog should be shown")
        return true
    }

    var shouldShowBadge: Bool {
        // The Connectivity Assist fallback resolver exists starting from iOS 27 only
        guard #available(iOS 27.0, *) else {
            DDLogInfo("(ConnectivityAssistWarningService) - badge is not shown, iOS version is lower than 27")
            return false
        }

        // The warning explains DNS filtering gaps, which the native implementation does not have
        guard resources.dnsImplementation == .adGuard else {
            DDLogInfo("(ConnectivityAssistWarningService) - badge is not shown, DNS implementation is not AdGuard")
            return false
        }

        // There is nothing to warn about while DNS protection is disabled
        // The system protection can be enabled by Pro users only,
        // see ComplexProtectionService.systemProtectionEnabled
        guard complexProtection.systemProtectionEnabled else {
            DDLogInfo("(ConnectivityAssistWarningService) - badge is not shown, system protection is disabled")
            return false
        }

        // Connectivity Assist bypasses the tunnel only in the split mode
        guard resources.tunnelMode == .split else {
            DDLogInfo("(ConnectivityAssistWarningService) - badge is not shown, tunnel mode is not split")
            return false
        }

        guard !resources.connectivityAssistBadgeShown else {
            DDLogInfo("(ConnectivityAssistWarningService) - badge is not shown, it has already been closed by the user")
            return false
        }

        DDLogInfo("(ConnectivityAssistWarningService) - badge should be shown")
        return true
    }

    func markDialogAsShown() {
        DDLogInfo("(ConnectivityAssistWarningService) - dialog is marked as shown")
        resources.connectivityAssistDialogShown = true
    }

    func markBadgeAsShown() {
        DDLogInfo("(ConnectivityAssistWarningService) - badge is marked as shown")
        resources.connectivityAssistBadgeShown = true
    }
}
