class SketchPadController < ApplicationController
	get '/sketch-pad' do
		erb :sketch_pad, :format => :html5, :layout => false
	end
end