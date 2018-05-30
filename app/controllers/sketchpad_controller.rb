class SketchpadController < ApplicationController
	get '/sketch-pad' do
		erb :sketch_pad, :layout => false
	end
end