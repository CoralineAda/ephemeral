ephemeral
=========

Ephemeral was created at Trunk Club to bring ORM-like functionality to non-persisted objects. The anticipated use case is for an application that consumes an API and materializes one or more collections of objects from a JSON response or XML response.

Please note that Ephemeral is currently in beta and is probably not ready for production use.

Example the First
=================

Let's say that we have an API server that stores information about the inventions of Nikola Tesla. We have another application that consumes this information. Our initial call to the API retrieves a list of all of his inventions, but we want to display them in categories. Assuming that we materialize each invention into an Invention object, the Ephemeral wiring is simple. Here's our sample Invention class:

    class Invention

      include Ephemeral::Base

      attr_accessor :name, :description, :category, :stolen_by_edison

      scope :telegraphy,    {:category => 'Telegraphy'}
      scope :electrical,    {:category => 'Electrical'}
      scope :mechanical,    {:category => 'Mechanical'}
      scope :stolen         {:stolen_by_edison => true }

      def initialize(args={})
        # Marshal object based on your API
      end

    end

We can now easily find all of Tesla's telegraphy inventions that were shamelessly stolen by Thomas Edison:

    Invention.telegraphy.stolen

Example the Second
==================

Our Tesla site has really taken off, and now we want to introduce another object, each instance of which represents a period in Tesla's life. We want to associate inventions with each of these periods. Again, rather than building complex logic into our API request, we can simply fetch a mass of data and build our relationships on the consumer application side using Ephemeral:

    class Period

      include Ephemeral::Base

      attr_accessor :name, :start_year, :end_year

      collects :inventions

      def initialize(args={})
        # Marshal object based on your API, including setting up Invention objects
      end

    end

Now we can filter inventions on the consumer side:

    period = Period.where(:name => 'Early Years')
    inventions = period.inventions.mechanical
    favorite = inventions.where(:name => 'Doomsday Device')

More Examples?
==============

For a more complete example, please refer to the specs.

