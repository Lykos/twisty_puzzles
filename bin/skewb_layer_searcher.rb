#!/usr/bin/ruby
# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'skewb_layer_searcher'
require 'skewb_transformation_describer'
require 'skewb_state'
require 'cube_print_helper'
require 'skewb_layer_searcher_options'
require 'csv'

include CubeTrainer
include CubePrintHelper

options = SkewbLayerSearcherOptions.parse(ARGV)
solutions = SkewbLayerSearcher.calculate(options.verbose, options.depth)

if options.verbose
  puts
  puts "#{solutions.length} solutions:" 
  puts

  state = SkewbState.solved
  solutions.each do |algs|
    algs.first.inverse.apply_temporarily_to(state) do
      puts skewb_string(state, :color)
      puts algs
      puts
    end
  end
end

if options.output
  state = SkewbState.solved
  yellow_corners = Corner::ELEMENTS.select { |c| c.colors.first == :yellow }
  white_corners = Corner::ELEMENTS.select { |c| c.colors.first == :white }
  non_bottom_faces = Face::ELEMENTS.select { |c| c.color != :white }
  layer_describer = SkewbTransformationDescriber.new([], white_corners)
  center_describer = SkewbTransformationDescriber.new(non_bottom_faces, [])
  top_corner_describer = SkewbTransformationDescriber.new([], yellow_corners)

  CSV.open(options.output, 'wb', {:col_sep => "\t"}) do |csv|
    csv << ['case description', 'main alg', 'center_transformations', 'top_corner_transformations', 'alternative algs', 'tags']
    solutions.each do |algs|
      main_alg, alternative_algs = algs[0], algs[1..-1]
      csv << [
        layer_describer.source_description(main_alg),
        main_alg.to_s,
        center_describer.transformation_description(main_alg),
        top_corner_describer.source_description(main_alg),
        alternative_algs.join(', '),
        "#{main_alg.length}_mover"
      ]
    end
  end
end