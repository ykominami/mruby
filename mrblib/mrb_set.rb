class Set
  include Enumerable

  def self.[](*ary)
    new(ary)
  end

  def initialize(enum = nil, &block)
    @hash ||= Hash.new

    enum.nil? and return

    if block_given?
      do_with_enum(enum) { |o| add(block.call(o)) }
    else
      merge(enum)
    end
  end

  def do_with_enum(enum, &block)
    if enum.respond_to?(:each)
      enum.each(&block)
    else
      raise ArgumentError, "value must be enumerable"
    end
  end
  private :do_with_enum

  def initialize_copy(orig)
    super
    @hash = orig.instance_variable_get(:@hash).dup
  end

  # def initialize_dup(orig)
  #   super
  #   @hash = orig.instance_variable_get(:@hash).dup
  # end

  # def initialize_clone(orig)
  #   super
  #   @hash = orig.instance_variable_get(:@hash).clone
  # end

  # def freeze
  #   @hash.freeze
  #   super
  # end

  # def taint
  #   @hash.taint
  #   super
  # end

  # def untaint
  #   @hash.untaint
  #   super
  # end

  def size
    @hash.size
  end
  alias length size

  def empty?
    @hash.empty?
  end

  def clear
    @hash.clear
    self
  end

  def replace(enum)
    clear
    merge(enum)
  end

  def to_a
    @hash.keys
  end

#  def to_set
#  end
#
#  def flatten_merge
#  end
#
#  def flatten
#  end
#
#  def flatten!
#  end

  def include?(o)
    @hash.include?(o)
  end
  alias member? include?

  def superset?(set)
    raise ArgumentError, "value must be a set" unless set.is_a?(Set)
    return false if size < set.size
    set.all? { |o| include?(o) }
  end
  alias >= superset?

  def proper_superset?(set)
    raise ArgumentError, "value must be a set" unless set.is_a?(Set)
    return false if size <= set.size
    set.all? { |o| include?(o) }
  end
  alias > proper_superset?

  def subset?(set)
    raise ArgumentError, "value must be a set" unless set.is_a?(Set)
    set.superset?(self)
  end
  alias <= subset?

  def proper_subset?(set)
    raise ArgumentError, "value must be a set" unless set.is_a?(Set)
    set.proper_superset?(self)
  end
  alias < proper_subset?

  def intersect?(set)
    raise ArgumentError, "value must be a set" unless set.is_a?(Set)
    if size < set.size
      any? { |o| set.include?(o) }
    else
      set.any? { |o| include?(o) }
    end
  end

 def disjoint?(set)
  !intersect?(set)
 end

  def each(&block)
    return to_enum :each unless block_given?
    @hash.each_key(&block)
    self
  end

  def add(o)
    @hash[o] = true
    self
  end
  alias << add

  def add?(o)
    if include?(o)
      nil
    else
      add(o)
    end
  end

  def delete(o)
    @hash.delete(o)
    self
  end

  def delete?(o)
    if include?(o)
      delete(o)
    else
      nil
    end
  end

  def delete_if
    return to_enum :delete_if unless block_given?
    select { |o| yield o }.each { |o| @hash.delete(o) }
    self
  end

  def keep_if
    return to_enum :keep_if unless block_given?
    reject { |o| yield o }.each { |o| @hash.delete(o) }
    self
  end

  def collect!
   return to_enum :collect! unless block_given?
   set = self.class.new
   each { |o| set << yield(o) }
   replace(set)
  end
  alias map! collect!

  def reject!(&block)
    return to_enum :reject! unless block_given?
    n = size
    delete_if(&block)
    size == n ? nil : self
  end

  def select!(&block)
    return to_enum :select! unless block_given?
    n = size
    keep_if(&block)
    size == n ? nil : self
  end

  def merge(enum)
    if enum.instance_of?(self.class)
      @hash.merge!(enum.instance_variable_get(:@hash))
    else
      do_with_enum(enum) { |o| add(o) }
    end

    self
  end

  def subtract(enum)
    do_with_enum(enum) { |o| delete(o) }
    self
  end

  def |(enum)
    dup.merge(enum)
  end
  alias + |
  alias union |

  def -(enum)
    dup.subtract(enum)
  end
  alias difference -

  def &(enum)
    n = Set.new
    do_with_enum(enum) { |o| n.add(o) if include?(o) }
    n
  end
  alias intersection &

  def ^(enum)
    (self | Set.new(enum)) - (self & Set.new(enum))
  end

  def ==(other)
    if self.equal?(other)
      true
    elsif other.instance_of?(self.class) && self.size == other.size
      other_hash = other.instance_variable_get(:@hash)
      other_hash.keys.all? { |o| @hash.keys.include?(o) }
      other_hash.values.all? { |o| @hash.values.include?(o) }
#      @hash == other.instance_variable_get(:@hash)
    elsif other.is_a?(self.class) && self.size == other.size
      other.all? { |o| include?(o) }
    else
      false
    end
  end

  def hash
    @hash.hash
  end

  def eql?(o)
    return false unless o.is_a?(Set)
    @hash.eql?(o.instance_variable_get(:@hash))
  end

  # def classify
  # end

  # def divide
  # end

  def inspect
    sprintf('#<%s: {%s}>', self.class, to_a.inspect[1..-2])
  end

end
