import UIKit

class WaypointSetAddViewController: UIViewController {
    private func loadWaypointSet(name: String, url: URL) async throws -> WaypointSet {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let (data, response) = try await session.data(from: url)
        let httpResponse = response as! HTTPURLResponse
        guard httpResponse.statusCode == 200 else {
            throw HTTPResponseError(response: httpResponse)
        }

        let waypoints = try WPTParser().parse(data)
        return WaypointSet(name: name, waypoints: waypoints)
    }

    @IBAction private func save() {
        guard self.saveTask == nil else {
            return
        }

        guard let urlText = self.urlTextField.text,
              let url = URL(string: urlText),
              let name = self.nameTextField.text else {
            return
        }

        self.saveTask = Task { @MainActor in
            do {
                let waypointSet = try await self.loadWaypointSet(name: name, url: url)
                try await self.waypointsManager.addWaypointSet(waypointSet)
                self.performSegue(withIdentifier: "dismiss", sender: self)
            } catch let e {
                let alertController = UIAlertController(
                    title: NSLocalizedString("Error", comment: ""),
                    message: e.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(
                    UIAlertAction(
                        title: NSLocalizedString("OK", comment: ""),
                        style: .default
                    )
                )
                self.present(alertController, animated: true)
            }

            self.saveTask = nil
        }
    }

    @IBAction private func cancel() {
        self.saveTask?.cancel()
        self.performSegue(withIdentifier: "dismiss", sender: self)
    }

    // MARK: UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.nameTextField.becomeFirstResponder()
    }

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var urlTextField: UITextField!
    @IBOutlet private var saveButton: UIBarButtonItem!

    private let waypointsManager: WaypointsManager = FileInjector.default.waypointsManager
    private var saveTask: Task<Void, Never>? {
        didSet {
            self.nameTextField.isEnabled = self.saveTask == nil
            self.urlTextField.isEnabled = self.saveTask == nil
            self.saveButton.isEnabled = self.saveTask == nil
        }
    }
}

class HTTPResponseError: Error {
    init(response: HTTPURLResponse) {
        self.response = response
    }

    let response: HTTPURLResponse
}
