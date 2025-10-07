import Foundation

/// A placeholder registry responsible for loading and managing AI/ML models.
/// This minimal implementation satisfies references in `HealthAIAssistantApp`.
final class ModelRegistry {
    /// Shared singleton instance used across the app.
    static let shared = ModelRegistry()

    private init() {}

    /// Load and prepare models for use. This is a no-op placeholder.
    /// Replace with real loading logic when models are integrated.
    func load() {
        // TODO: Implement model loading/registration as needed.
    }
}
