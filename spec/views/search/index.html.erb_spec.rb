require 'rails_helper'

describe 'search/index.html.erb' do
  let(:user)           { Fabricate(:user) }
  let(:memories)       { Fabricate.times(3, :photo_memory, user: user) }
  let(:paged_memories) { Kaminari.paginate_array(memories).page(1) }
  let(:params_stub)    { {query: 'test search'}  }

  before :each do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:params).and_return(params_stub)
    assign(:memories, paged_memories)
    render
  end

  it 'displays the result count' do
    expect(rendered).to have_css('#contentHeader', text: "Found 3 matches for \"#{params_stub[:query]}\"")
  end

  context 'a memory' do
    let(:memory) { memories.first }

    it 'is a link to the show page for that memory' do
      expect(rendered).to have_css("a.memory[href=\"#{memory_path(memory)}\"]")
    end
  end

  it_behaves_like 'a memory index'
  it_behaves_like 'paginated content'
end
