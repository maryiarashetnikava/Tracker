import UIKit

final class StatisticsViewController: UIViewController {
    
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    
    private let stackView = UIStackView()

    private let bestPeriodView = StatisticsView()
    private let perfectDaysView = StatisticsView()
    private let completedTrackersView = StatisticsView()
    private let averageValueView = StatisticsView()
    
    init(
        trackerStore: TrackerStore,
        recordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = NSLocalizedString("statistics.title", comment: "")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        setupEmptyState()
        setupStatisticsViews()
        
        updateStatisticsState()
        updateStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateStatistics()
        updateStatisticsState()
    }
    
    private func completedTrackersCount() -> Int {
        recordStore.fetchRecords().count
    }
    
    private func updateStatisticsState() {

        let hasStatistics = completedTrackersCount() > 0

        emptyImageView.isHidden = hasStatistics
        emptyLabel.isHidden = hasStatistics

        stackView.isHidden = !hasStatistics
    }
    
    private func averageValue() -> Int {

        let records = recordStore.fetchRecords()

        guard !records.isEmpty else {
            return 0
        }

        let groupedRecords = Dictionary(
            grouping: records
        ) { record in
            Calendar.current.startOfDay(
                for: record.date ?? Date()
            )
        }

        let totalCompleted = records.count
        let daysCount = groupedRecords.count

        return totalCompleted / daysCount
    }
    
    private func perfectDaysCount() -> Int {

        let records = recordStore.fetchRecords()

        guard !records.isEmpty else {
            return 0
        }

        let groupedRecords = Dictionary(
            grouping: records
        ) { record in
            Calendar.current.startOfDay(
                for: record.date ?? Date()
            )
        }

        var perfectDays = 0

        for (date, dayRecords) in groupedRecords {

            guard let weekday = Weekday(
                rawValue: Calendar.current.component(
                    .weekday,
                    from: date
                )
            ) else {
                continue
            }

            let scheduledTrackers = trackerStore.trackers.filter { tracker in

                let schedule = tracker.schedule as? [Weekday] ?? []

                return schedule.contains(weekday)
            }

            if dayRecords.count == scheduledTrackers.count {
                perfectDays += 1
            }
        }

        return perfectDays
    }
    
    private func bestPeriodCount() -> Int {

        let records = recordStore.fetchRecords()

        guard !records.isEmpty else {
            return 0
        }

        let groupedRecords = Dictionary(
            grouping: records
        ) { record in
            record.trackerId ?? UUID()
        }

        var bestPeriod = 0

        let calendar = Calendar.current

        for (_, trackerRecords) in groupedRecords {

            let dates = trackerRecords
                .compactMap(\.date)
                .sorted()

            guard !dates.isEmpty else {
                continue
            }

            var currentStreak = 1
            var maxStreak = 1

            for index in 1..<dates.count {

                let previousDate = dates[index - 1]
                let currentDate = dates[index]

                let days = calendar.dateComponents(
                    [.day],
                    from: previousDate,
                    to: currentDate
                ).day ?? 0

                if days == 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }

                maxStreak = max(
                    maxStreak,
                    currentStreak
                )
            }

            bestPeriod = max(
                bestPeriod,
                maxStreak
            )
        }

        return bestPeriod
    }
    
    private func updateStatistics() {
        
        completedTrackersView.configure(
            value: completedTrackersCount(),
            title: NSLocalizedString(
                "statistics.completedTrackers",
                comment: ""
            )
        )

        averageValueView.configure(
            value: averageValue(),
            title: NSLocalizedString(
                "statistics.averageValue",
                comment: ""
            )
        )
        
        perfectDaysView.configure(
            value: perfectDaysCount(),
            title: NSLocalizedString(
                "statistics.perfectDays",
                comment: ""
            )
        )
        
        bestPeriodView.configure(
            value: bestPeriodCount(),
            title: NSLocalizedString(
                "statistics.bestPeriod",
                comment: ""
            )
        )
    }
    
}

private extension StatisticsViewController {

    func setupEmptyState() {

        emptyImageView.image = UIImage(
            resource: .statisticsEmpty
        )

        emptyImageView.contentMode = .scaleAspectFit

        emptyLabel.text = NSLocalizedString(
            "statistics.empty",
            comment: ""
        )

        emptyLabel.font = UIFont.systemFont(
            ofSize: 12,
            weight: .medium
        )

        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .label

        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)

        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            emptyImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            emptyImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),

            emptyLabel.topAnchor.constraint(
                equalTo: emptyImageView.bottomAnchor,
                constant: 8
            ),

            emptyLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
}

private extension StatisticsViewController {

    func setupStatisticsViews() {

        stackView.axis = .vertical
        stackView.spacing = 12

        [
            bestPeriodView,
            perfectDaysView,
            completedTrackersView,
            averageValueView
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 77
            ),

            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            )
        ])
    }
}


