require 'date'
require 'active_support/inflector'

class Spanner

  ParseError = Class.new(RuntimeError)

  def self.parse(str, opts = nil)
    Spanner.new(opts).parse(str)
  end
  
  def self.format(distance, opts = nil)
    Spanner.new(opts).format(distance)
  end
  
  attr_reader :value, :raise_on_error, :from
  
  def initialize(opts)
    @value = value
    @on_error = opts && opts.key?(:on_error) ? opts[:on_error] : :raise
    @length_of_month = opts && opts[:length_of_month]
    @biggest_unit = ((opts && opts[:biggest_unit]) || "years").to_s.downcase.to_sym
    
    @from = if opts && opts.key?(:from)
      case opts[:from]
      when :now
        Time.new.to_i
      else 
        opts[:from].to_i
      end
    else
      0
    end
  end
  
  def self.days_in_month(year, month)
    (Date.new(year, 12, 31) << (12-month)).day
  end
  
  def length_of_month
    @length_of_month ||= Spanner.parse("#{Spanner.days_in_month(Time.new.year, Time.new.month)} days")
  end
  
  def error(err)
    if on_error == :raise
      raise ParseError.new(err)
    end
  end
  
  def parse(value)
    parts = []
    part_contextualized = nil
    value.to_s.scan(/[\+\-]?(?:\d*\.\d+|\d+)|[a-z]+/i).each do |part|
      part_as_float = Float(part) rescue nil
      if part_as_float
        parts << part_as_float
        part_contextualized = nil
      else
        if part_contextualized
          error "Part has already been contextualized with #{part_contextualized}"
          return nil
        end
        
        if parts.empty?
          parts << 1
        end
        
        # part is context
        multiplier = case part
        when 's', 'sec', 'second', 'seconds'  then 1
        when 'h', 'hour', 'hours', 'hrs'      then 3600
        when 'm', 'min', 'minute', 'minutes'  then 60
        when 'd', 'day', 'days'               then 86_400
        when 'w', 'wks', 'week', 'weeks'      then 604_800
        when 'months', 'month', 'M'           then length_of_month
        when 'years', 'year', 'y'             then 31_556_926
        when /\As/                            then 1
        when /\Am/                            then 60
        when /\Ah/                            then 3600
        when /\Ad/                            then 86_400
        when /\Aw/                            then 604_800
        when /\AM/                            then length_of_month
        when /\Ay/                            then 31_556_926
        end
        
        part_contextualized = part
        parts << (parts.pop * multiplier) if multiplier
      end
    end
    
    if parts.empty?
      nil
    else
      value = parts.inject(from) {|s, p| s += p}
      value.ceil == value ? value.ceil : value
    end
  end
  
  def format(distance)
    distance = distance.to_i
    
    units = [:years, :months, :weeks, :days, :hours, :minutes]
    biggest_unit = units.index(@biggest_unit) || 0
    
    parts = {}
    parts[:years], distance = distance.divmod(31_556_926) unless biggest_unit > units.index(:years)
    parts[:months], distance = distance.divmod(length_of_month) unless biggest_unit > units.index(:months)
    parts[:weeks], distance = distance.divmod(604_800) unless biggest_unit > units.index(:weeks)
    parts[:days], distance = distance.divmod(86_400) unless biggest_unit > units.index(:days)
    parts[:hours], distance = distance.divmod(3600) unless biggest_unit > units.index(:hours)
    parts[:minutes], parts[:seconds] = distance.divmod(60) unless biggest_unit > units.index(:minutes)
    
    output = []
    parts.each do |name, value|
      next if value == 0
      name = name.to_s.singularize if value.between?(-1, 1)
      output << "%d %s" % [value, name]
    end
    output.join(" ")
  end
end