Pod::Spec.new do |s|

  s.name = "HQChannelListView"
  s.version = "0.0.1"
  s.license = "MIT"
  s.summary = "A ChannelListView with CollectionView by swift, it is like NetEaseNews Channel style."
  s.homepage = "https://github.com/hongqingWang/HQChannelListView"
  s.author = { "hongqingWang" => "272338444@qq.com" }
  s.source = { :git => "https://github.com/hongqingWang/HQChannelListView.git", :tag => s.version }

  s.ios.deployment_target = "8.0"

  s.source_files  = "HQChannelListView", "HQChannelListView/*.swift"
  s.requires_arc = true
end
