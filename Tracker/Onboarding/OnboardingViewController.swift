import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Properties
    
    private var pages: [UIViewController] = []
    var onFinish: (() -> Void)?
    
    // MARK: - Data

    private let pagesData: [OnboardingPageModel] = [
        OnboardingPageModel(
            text: NSLocalizedString("onboarding.first", comment: ""),
            backgroundImage: UIImage(resource: .onboardingBlue)
        ),
        OnboardingPageModel(
            text: NSLocalizedString("onboarding.second", comment: ""),
            backgroundImage: UIImage(resource: .onboardingRed)
        )
    ]
    
    // MARK: - UI

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPages()
        setupPageViewController()
        setupPageControl()
    }
    
    // MARK: - Setup Pages

    private func setupPages() {
        pages = pagesData.map { model in
            let vc = OnboardingPageViewController(model: model)
            
            vc.onButtonTap = { [weak self] in
                self?.finishOnboarding()
            }
            
            return vc
        }
    }
    
    // MARK: - Setup PageVC

    private func setupPageViewController() {
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
    }
    
    // MARK: - Setup PageControl

    private func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Private Methods

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        onFinish?()
    }
}


// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = index - 1
        
        if previousIndex < 0 {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = index + 1
        
        if nextIndex >= pages.count {
            return pages.first
            
        }
            
            return pages[nextIndex]
    }
}
    
// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        guard completed,
              let currentVC = viewControllers?.first,
              let index = pages.firstIndex(of: currentVC) else {
            return
        }
        
        pageControl.currentPage = index
    }
}
    
