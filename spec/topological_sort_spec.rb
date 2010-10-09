require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'topological_sort' do
  describe 'on an empty graph' do    
    it 'returns an empty list' do
      topological_sort([]).should == []
    end
  end
  
  describe 'on a double-star graph' do
    before do
      @graph = {1 => [2, 3, 4], 5 => [6, 7, 8]}
      @roots = [1, 5]
    end
    
    it 'returns nodes in exit order' do
      result = topological_sort(@roots) { |node| { :next => @graph[node] } }
      result.should == [2, 3, 4, 1, 6, 7, 8, 5]
    end
    
    it 'uses node IDs if given' do
      result = topological_sort(@roots) do |node|
        { :id => node / 2, :next => @graph[node] }
      end
      result.should == [2, 4, 1]
    end
  end
  
  describe 'on a hairy graph' do
    before do
      @graph = {1 => [2, 3, 4], 2 => [5, 6, 7], 3 => [6, 7, 8], 4 => [7, 8, 9]}      
    end
    
    it 'returns nodes in exit order' do
      result = topological_sort([1]) { |node| { :next => @graph[node] } }
      result.should == [5, 6, 7, 2, 8, 3, 9, 4, 1]
    end
  end

  describe 'on a hairy graph with a cycle' do
    before do
      @graph = {1 => [2, 3, 4], 2 => [5, 6, 7], 3 => [6, 7, 8], 4 => [7, 8, 9],
                8 => [11, 4]}
    end
    
    it 'raises an exception' do
      lambda {
        topological_sort([1]) { |node| { :next => @graph[node] } }
      }.should raise_error(ArgumentError)
    end
  end

  describe 'on a hairy graph with a self-reference' do
    before do
      @graph = {1 => [2, 3, 4], 2 => [5, 6, 7], 3 => [6, 7, 8], 4 => [7, 8, 9],
                8 => [11, 8]}
    end
    
    it 'raises an exception' do
      lambda {
        topological_sort([1]) { |node| { :next => @graph[node] } }
      }.should raise_error(ArgumentError)
    end
  end
end
