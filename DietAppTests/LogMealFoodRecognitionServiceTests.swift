import XCTest
@testable import DietApp

final class LogMealFoodRecognitionServiceTests: XCTestCase {
    func testMakeResultsParsesCaloriesProteinAndFat() throws {
        let json = """
        {
          "foodName": "Chicken Caesar Salad",
          "hasNutritionalInfo": true,
          "imageId": 3,
          "serving_size": 350.0,
          "nutritional_info": {
            "calories": 420.5,
            "totalNutrients": {
              "ENERC_KCAL": {"label": "Energy", "quantity": 420.5, "unit": "kcal"},
              "PROCNT": {"label": "Protein", "quantity": 32.1, "unit": "g"},
              "FAT": {"label": "Fat", "quantity": 18.4, "unit": "g"},
              "CHOCDF": {"label": "Carbs", "quantity": 25.0, "unit": "g"}
            }
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(NutritionalInfoResponse.self, from: json)
        let results = LogMealFoodRecognitionService.makeResults(from: response)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].foodName, "Chicken Caesar Salad")
        XCTAssertEqual(results[0].estimatedCalories, 420.5)
        XCTAssertEqual(results[0].proteinGrams, 32.1)
        XCTAssertEqual(results[0].fatGrams, 18.4)
    }

    func testMakeResultsHandlesArrayFoodNameAndMissingNutrients() throws {
        let json = """
        {
          "foodName": ["Rice", "Miso Soup"],
          "hasNutritionalInfo": true,
          "imageId": 7,
          "nutritional_info": {
            "calories": 300.0,
            "totalNutrients": {}
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(NutritionalInfoResponse.self, from: json)
        let results = LogMealFoodRecognitionService.makeResults(from: response)

        XCTAssertEqual(results[0].foodName, "Rice・Miso Soup")
        XCTAssertEqual(results[0].proteinGrams, 0)
        XCTAssertEqual(results[0].fatGrams, 0)
    }

    func testSegmentationResponseDecodesImageId() throws {
        let json = """
        {
          "imageId": 42,
          "processed_image_size": {"width": 800, "height": 600},
          "segmentation_results": []
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(SegmentationResponse.self, from: json)
        XCTAssertEqual(response.imageId, 42)
    }
}
