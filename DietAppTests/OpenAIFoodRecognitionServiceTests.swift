import XCTest
@testable import DietApp

final class OpenAIFoodRecognitionServiceTests: XCTestCase {
    func testMakeResultsMapsMultipleItems() throws {
        let json = """
        {
          "items": [
            {"foodName": "白ご飯", "calories": 250, "proteinGrams": 4.5, "fatGrams": 0.5},
            {"foodName": "焼き鮭", "calories": 180, "proteinGrams": 20.0, "fatGrams": 10.0}
          ]
        }
        """.data(using: .utf8)!

        let analysis = try JSONDecoder().decode(FoodAnalysis.self, from: json)
        let results = OpenAIFoodRecognitionService.makeResults(from: analysis)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], FoodRecognitionResult(foodName: "白ご飯", estimatedCalories: 250, proteinGrams: 4.5, fatGrams: 0.5))
        XCTAssertEqual(results[1], FoodRecognitionResult(foodName: "焼き鮭", estimatedCalories: 180, proteinGrams: 20.0, fatGrams: 10.0))
    }

    func testChatResponseDecodesNestedJSONStringContent() throws {
        let json = """
        {
          "choices": [
            {
              "message": {
                "content": "{\\"items\\": [{\\"foodName\\": \\"カレーライス\\", \\"calories\\": 700, \\"proteinGrams\\": 15, \\"fatGrams\\": 20}]}"
              }
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ChatResponse.self, from: json)
        let content = try XCTUnwrap(response.choices.first?.message.content)
        let analysis = try JSONDecoder().decode(FoodAnalysis.self, from: try XCTUnwrap(content.data(using: .utf8)))

        XCTAssertEqual(analysis.items.first?.foodName, "カレーライス")
        XCTAssertEqual(analysis.items.first?.calories, 700)
    }

    func testChatRequestEncodesModelAndImageAsDataURL() throws {
        let request = ChatRequest(model: "gpt-4o-mini", imageBase64: "AAAA")
        let data = try JSONEncoder().encode(request)
        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(jsonString.contains("\"model\":\"gpt-4o-mini\""))
        XCTAssertTrue(jsonString.contains("data:image\\/jpeg;base64,AAAA"))
        XCTAssertTrue(jsonString.contains("\"response_format\""))
    }
}
