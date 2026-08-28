import Foundation

// 0円制約のため外部の飲食店・ジムAPIは使わず、まずは固定の候補リストから提案する。
enum SuggestionCatalog {
    static let meals: [MealSuggestion] = [
        MealSuggestion(title: "サラダチキンとおにぎり", description: "コンビニで手軽に。たんぱく質を確保しつつ低カロリー。", estimatedCalories: 350),
        MealSuggestion(title: "豆腐と野菜の味噌汁+雑穀ご飯", description: "軽めに済ませたい時に。", estimatedCalories: 300),
        MealSuggestion(title: "鶏むね肉の蒸し鶏定食", description: "自炊でも定食屋でも。脂質を抑えつつ満足感あり。", estimatedCalories: 450),
        MealSuggestion(title: "焼き魚定食(サバ・鮭など)", description: "定食屋で。良質な脂質とたんぱく質。", estimatedCalories: 550),
        MealSuggestion(title: "牛丼(並盛・つゆだく抜き)", description: "外食チェーンで。ボリュームが欲しい時に。", estimatedCalories: 650),
        MealSuggestion(title: "パスタ(トマト系)", description: "少し多めに食べたい日に。クリーム系より低カロリー。", estimatedCalories: 700)
    ]

    static let workouts: [WorkoutSuggestion] = [
        WorkoutSuggestion(title: "ウォーキング30分", description: "軽めの調整に。", estimatedCaloriesBurned: 120),
        WorkoutSuggestion(title: "ジョギング30分", description: "少し息が上がるペースで。", estimatedCaloriesBurned: 250),
        WorkoutSuggestion(title: "ジムでの筋トレ(45分)", description: "全身メニュー中心に。", estimatedCaloriesBurned: 300),
        WorkoutSuggestion(title: "水泳30分", description: "全身運動で消費カロリーも高め。", estimatedCaloriesBurned: 350),
        WorkoutSuggestion(title: "エアロバイク45分", description: "膝への負担が少ない有酸素運動。", estimatedCaloriesBurned: 400)
    ]
}
