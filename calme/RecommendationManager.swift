import Foundation
import CoreML

final class RecommendationManager {

    private var model: CalmingRecommendation?

    init() {
        do {
            self.model = try CalmingRecommendation(configuration: MLModelConfiguration())
        } catch {
            print("RecommendationManager: failed to load model — \(error)")
            self.model = nil
        }
    }

    // MARK: - Get Recommendations

    func getRecommendations(
        items: [String: Double],
        k: Int = 3,
        restrict: [String]? = nil,
        exclude: [String]? = nil
    ) -> [RecommendationResult] {

        guard let model else {
            print("RecommendationManager: model unavailable, returning empty list.")
            return []
        }

        do {
            let prediction = try model.prediction(
                items: items,
                k: Int64(k),
                restrict_: restrict,
                exclude: exclude
            )

            return prediction.recommendations.map { item in
                RecommendationResult(
                    name: item,
                    score: prediction.scores[item] ?? 0.0
                )
            }

        } catch {
            print("RecommendationManager: prediction error — \(error)")
            return []
        }
    }
}

// MARK: - Recommendation Result

struct RecommendationResult: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
}
