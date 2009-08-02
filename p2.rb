#!/usr/bin/env ruby
@@hits = {}
def add_subsequences!(gid, sequence)
  sequence.gsub(/ATG([ACGT]{1,5}?)ATG/) do |m|
    match = $&
    if(match =~ /C/)
      @@hits[gid] = [] unless @@hits.has_key? gid # create a key w/ genome_id if not existing
      @@hits[gid] << match
      @@hits[gid].sort! {|x,y| y.length <=> x.length }
    end
  end
end
if $stdin.tty? { puts "This program takes input from STDIN only."; exit }
else
  while !$stdin.eof? do
    genome_id = gets
    if genome_id =~ /^>(REC\d{5})$/
      genome_id = $1 # strip the leading < off the front of the genome_id
      gene_sequence = gets
      if gene_sequence =~ /ATG(.{1,5})ATG/ # see if there might be a possible matching subsequence       
        add_subsequences!(genome_id, gene_sequence)
      end
    end 
  end
  if @@hits.empty? { puts 'There were no matching genomes'; exit }
  else 
    line = '#####################'; puts line
    @@hits.each_pair do |gid, gseq|  
      gseq.each { |seq| puts "#{gid}: #{seq}"}
      puts line
    end
  end
end
