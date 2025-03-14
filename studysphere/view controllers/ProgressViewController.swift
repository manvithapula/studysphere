//
//  ProgressViewController.swift
//  studysphere
//
//  Created by dark on 02/11/24.
//

import Charts
import DGCharts
import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet weak var flashcardMainL: UILabel!
    @IBOutlet weak var questionMainL: UILabel!
    @IBOutlet weak var hourMainL: UILabel!
    @IBOutlet weak var flashcardSecondaryL: UILabel!
    @IBOutlet weak var questionSecondaryL: UILabel!
    @IBOutlet weak var timeValueL: UILabel!
    @IBOutlet weak var timeTypeL: UILabel!
    @IBOutlet weak var streakValueL: UILabel!
    @IBOutlet weak var streakTypeL: UILabel!

    @IBOutlet weak var flashcardP: UIProgressView!
    @IBOutlet weak var questionP: UIProgressView!

    @IBOutlet weak var multiProgressRing: UIView!
    @IBOutlet weak var questionChartView: UIView!
    private let streakLineChartView = LineChartView()
    private let questionLineChartView = LineChartView()
    
    private let scoreBarChartView = BarChartView() 
    @IBOutlet weak var scoreChartContainer: UIView!

    fileprivate func updateUI() {
        Task {

            createChartContainer(
                title: "Spaced Repetition", chartView: streakLineChartView,
                container: multiProgressRing)
            createChartContainer(
                title: "Active Recall", chartView: questionLineChartView,
                container: questionChartView)
            createChartContainer(
                            title: "Performance Scores", chartView: scoreBarChartView,
                            container: scoreChartContainer)
            await configureStreakLineChart(
                lineChart: streakLineChartView, topic: TopicsType.flashcards)
            await configureStreakLineChart(
                lineChart: questionLineChartView, topic: TopicsType.quizzes)
            await configureScoreBarChart(barChart: scoreBarChartView)

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Progress"
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    private func getLastWeekCount(
        type: TopicsType, timeInterval: Calendar.Component
    ) async throws -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let lastWeek = Calendar.current.date(
            byAdding: timeInterval, value: -1, to: today)!

        // Get schedules asynchronously
        let schedules = try await schedulesDb.findAll(where: [
            "topicType": type.rawValue
        ])

        // Filter schedules
        let lastWeekSchedules = schedules.filter {
            let scheduleDate = Calendar.current.startOfDay(
                for: $0.date.dateValue())
            return scheduleDate >= lastWeek && scheduleDate <= today
        }

        return lastWeekSchedules.count
    }
    private func getLastWeekCompletedCount(
        type: TopicsType, timeInterval: Calendar.Component
    ) async throws -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let lastWeek = Calendar.current.date(
            byAdding: timeInterval, value: -1, to: today)!
        let schedules = try await schedulesDb.findAll(where: [
            "topicType": type.rawValue
        ])

        let lastWeekSchedules = schedules.filter {
            let scheduleDate = Calendar.current.startOfDay(
                for: $0.date.dateValue())
            return scheduleDate >= lastWeek && scheduleDate <= today
                && $0.completed != nil
        }
        return lastWeekSchedules.count
    }
    private func createProgress(
        type: TopicsType, timeInterval: Calendar.Component
    ) async -> ProgressType {
        let lastWeekCount = try! await getLastWeekCount(
            type: type, timeInterval: timeInterval)
        let lastWeekCompletedCount = try! await getLastWeekCompletedCount(
            type: type, timeInterval: timeInterval)
        print(type, lastWeekCount, lastWeekCompletedCount)
        return ProgressType(
            completed: lastWeekCompletedCount, total: lastWeekCount)
    }

    private func createChartContainer(
        title: String, chartView: UIView, container: UIView
    ) {
        container.backgroundColor = AppTheme.secondary.withAlphaComponent(0.1)
        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.layer.shadowOpacity = 0.1

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        chartView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(chartView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor, constant: -16),

            chartView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 8),
            chartView.leadingAnchor.constraint(
                equalTo: container.leadingAnchor, constant: 8),
            chartView.trailingAnchor.constraint(
                equalTo: container.trailingAnchor, constant: -8),
            chartView.bottomAnchor.constraint(
                equalTo: container.bottomAnchor, constant: -16),
        ])

    }
    private func getStreakChartData(
        topic: TopicsType, for timeInterval: Calendar.Component = .day
    )
        async throws -> (days: [String], questions: [Int], flashcards: [Int])
    {
        let today = Calendar.current.startOfDay(for: Date())
        var dayLabels: [String] = []
        var questionValues: [Int] = []
        var flashcardValues: [Int] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"

        for dayOffset in (0...6).reversed() {
            let currentDate = Calendar.current.date(
                byAdding: .day, value: -dayOffset, to: today)!

            let dayLabel = dateFormatter.string(from: currentDate)
            dayLabels.append(dayLabel)

            let startOfDay = Calendar.current.startOfDay(for: currentDate)
            let endOfDay = Calendar.current.date(
                byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(
                    -1)

            let questionCount = try await getCountForDay(
                type: topic,
                startDate: startOfDay,
                endDate: endOfDay,
                completed: false
            )
            questionValues.append(questionCount)

            let flashcardCount = try await getCountForDay(
                type: topic,
                startDate: startOfDay,
                endDate: endOfDay,
                completed: true
            )
            flashcardValues.append(flashcardCount)
        }

        return (
            days: dayLabels, questions: questionValues,
            flashcards: flashcardValues
        )
    }

    private func getCountForDay(
        type: TopicsType, startDate: Date, endDate: Date, completed: Bool
    ) async throws -> Int {
        let schedules = try await schedulesDb.findAll(where: [
            "topicType": type.rawValue
        ])

        let daySchedules = schedules.filter { schedule in
            let scheduleDate = schedule.date.dateValue()
            return scheduleDate >= startDate && scheduleDate <= endDate
                && (completed ? schedule.completed != nil : true)
        }

        return daySchedules.count
    }

    private func configureStreakLineChart(
        lineChart: LineChartView, topic: TopicsType
    ) async {
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false

        do {
            let chartData = try await getStreakChartData(topic: topic)

            let questionsEntries = chartData.questions.enumerated().map {
                index, value in
                return ChartDataEntry(x: Double(index), y: Double(value))
            }

            let questionsDataSet = LineChartDataSet(
                entries: questionsEntries, label: "Missed  ")
            questionsDataSet.colors = [AppTheme.primary.withAlphaComponent(0.5)]
            questionsDataSet.circleColors = [
                AppTheme.primary.withAlphaComponent(0.5)
            ]
            questionsDataSet.lineWidth = 2
            questionsDataSet.circleRadius = 4
            questionsDataSet.drawCircleHoleEnabled = false
            questionsDataSet.mode = .linear

            let flashcardsEntries = chartData.flashcards.enumerated().map {
                index, value in
                return ChartDataEntry(x: Double(index), y: Double(value))
            }

            let flashcardsDataSet = LineChartDataSet(
                entries: flashcardsEntries, label: "Completed")
            flashcardsDataSet.colors = [AppTheme.primary]
            flashcardsDataSet.circleColors = [AppTheme.primary]
            flashcardsDataSet.lineWidth = 2
            flashcardsDataSet.circleRadius = 4
            flashcardsDataSet.drawCircleHoleEnabled = false
            flashcardsDataSet.mode = .linear

            questionsDataSet.drawValuesEnabled = false

            flashcardsDataSet.drawValuesEnabled = false

            let data = LineChartData(dataSets: [
                questionsDataSet, flashcardsDataSet,
            ])
            data.setValueFont(.systemFont(ofSize: 10))

            lineChart.data = data
            lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(
                values: chartData.days)
            lineChart.xAxis.granularity = 1
            lineChart.xAxis.labelPosition = .bottom
            lineChart.rightAxis.enabled = false
            lineChart.legend.font = .systemFont(ofSize: 12)
            lineChart.animate(
                xAxisDuration: 1.0, easingOption: .easeInOutSine)
        } catch {
            print("Error fetching streak chart data: \(error)")
        }
    }
    private func getRecentScores() async throws -> [Score] {
            let today = Calendar.current.startOfDay(for: Date())
            let oneMonthAgo = Calendar.current.date(
                byAdding: .month, value: -1, to: today)!
                
            // Get scores from database (assuming you have a scoresDb similar to schedulesDb)
        let scores = try await scoreDb.findAll()
            
            let recentScores = scores.filter {
                let scoreDate = Calendar.current.startOfDay(
                    for: $0.createdAt.dateValue())
                return scoreDate >= oneMonthAgo && scoreDate <= today
            }
            
            return recentScores
        }
        
        // Method to calculate average scores by topic
        private func getAverageScoresByTopic() async throws -> [(topicId: String, averageScore: Double, totalAttempts: Int)] {
            let scores = try await getRecentScores()
            
            // Group scores by topic ID
            var scoresByTopic: [String: [Score]] = [:]
            for score in scores {
                if scoresByTopic[score.topicId] == nil {
                    scoresByTopic[score.topicId] = []
                }
                scoresByTopic[score.topicId]?.append(score)
            }
            
            // Calculate average score for each topic
            var results: [(topicId: String, averageScore: Double, totalAttempts: Int)] = []
            for (topicId, topicScores) in scoresByTopic {
                let totalScore = topicScores.reduce(0) { $0 + $1.score }
                let totalPossible = topicScores.reduce(0) { $0 + $1.total }
                let averagePercentage = totalPossible > 0 ? Double(totalScore) / Double(totalPossible) * 100.0 : 0
                results.append((topicId: topicId, averageScore: averagePercentage, totalAttempts: topicScores.count))
            }
            
            // Sort by average score (highest first)
            return results.sorted { $0.averageScore > $1.averageScore }
        }
        
        // Configure bar chart to display scores
        private func configureScoreBarChart(barChart: BarChartView) async {
            do {
                barChart.xAxis.drawGridLinesEnabled = false
                barChart.leftAxis.drawGridLinesEnabled = false
                barChart.rightAxis.drawGridLinesEnabled = false

                let scoreData = try await getAverageScoresByTopic()
                
                // Limit to top 5 topics if there are more
                let topScores = Array(scoreData.prefix(5))
                
                // Create entries for the bar chart
                var entries: [BarChartDataEntry] = []
                var topicLabels: [String] = []
                
                for (index, scoreInfo) in topScores.enumerated() {
                    let entry = BarChartDataEntry(x: Double(index), y: scoreInfo.averageScore)
                    entries.append(entry)
                    
                    // Get topic name (you might need to fetch this from a topics database)
                    // For now, just use the topic ID
                    if let topic = topicsDb.findFirst(where: ["id":scoreInfo.topicId]){
                        topicLabels.append(topic.title)
                    }
                    else{
                        topicLabels.append(scoreInfo.topicId)
                    }
                    
                    // You could fetch full topic names like this:
                    // let topic = try await topicsDb.find(id: scoreInfo.topicId)
                    // topicLabels.append(topic.name)
                }
                
                let dataSet = BarChartDataSet(entries: entries, label: "Average Score (%)")
                
                // Style the bars
                dataSet.colors = [AppTheme.primary]
                dataSet.valueTextColor = .label
                dataSet.valueFont = .systemFont(ofSize: 10)
                
                // Format value labels as percentages
                let valueFormatter = NumberFormatter()
                valueFormatter.numberStyle = .decimal
                valueFormatter.maximumFractionDigits = 1
                dataSet.valueFormatter = DefaultValueFormatter(formatter: valueFormatter)
                
                let data = BarChartData(dataSet: dataSet)
                data.barWidth = 0.6
                barChart.data = data
                
                // Configure axes
                barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: topicLabels)
                barChart.xAxis.labelPosition = .bottom
                barChart.xAxis.granularity = 1
//                barChart.xAxis.labelRotationAngle = -45 // Rotate labels if topic names are long
                
                barChart.leftAxis.axisMinimum = 0
                barChart.leftAxis.axisMaximum = 100 // 100% maximum
                barChart.leftAxis.granularity = 20
                
                barChart.rightAxis.enabled = false
                barChart.legend.enabled = false
                
                
                barChart.animate(yAxisDuration: 1.0)
                
            } catch {
                print("Error fetching and displaying score data: \(error)")
            }
        }

}


class BarChartMarkerView: MarkerView {
    private let color: UIColor
    private let font: UIFont
    private let textColor: UIColor
    
    init(color: UIColor, font: UIFont, textColor: UIColor) {
        self.color = color
        self.font = font
        self.textColor = textColor
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        self.offset = CGPoint(x: 0, y: -10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let attempt = "Attempts: \(Int(entry.data as? Int ?? 0))"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedString = NSMutableAttributedString(string: attempt)
        attributedString.setAttributes([.font: font, .foregroundColor: textColor, .paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attempt.count))
        
        (self.subviews[0] as? UILabel)?.attributedText = attributedString
    }
    
     func draw(_ rect: CGRect, context: CGContext) {
        // Draw rounded rect background
        let roundedRect = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        
        context.setFillColor(color.cgColor)
        context.beginPath()
        context.addPath(UIBezierPath(roundedRect: roundedRect, cornerRadius: 5).cgPath)
        context.closePath()
        context.fillPath()
    }
}
