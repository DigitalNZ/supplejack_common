# Supplejack Harvester Core

The Supplejack Harvester Core provides the Parser DSL that is used in the [Supplejack Manager](https://github.com/DigitalNZ/supplejack_manager) and [Supplejack Worker](https://github.com/DigitalNZ/supplejack_worker)

## Architecture

It follows a very simple architecture where you have adapters or strategies for different types of harvests that abstract most of the complexity and let the harvest operator use a common language for defining how to extract the important data from every source.

## Adapters

The following adapters have been implemented:

* Open Archives Initiative
* Really Simple Syndication
* XML
* JSON

Each adapter is very easy to implement, for the current adapters they only have between 60 and 100 lines of code each.

## Parser definition

The parser files for the different sources are defined using a Domain Specific Language which exposes methods or constructs to fetch and extract the needed pieces of information from each source. This way the important details of each parser file are expressed in a more conscise and elegenant manner thereby enhancing the quality, maintainability, ease of use as well as reducing the proneness to errors.

### Parser file methods

#### base_url
It takes a url as a argument which will be used to fetch the resources.

#### attribute / attributes
It takes the name of the attribute and then some options to specify how that particular field is going to be populated. It can additionally take a block in which any custom logic can be defined.

#### Method definitons
Any method defined in the parser file will also be used as a attribute for the resource, the difference being that you have access to the raw document or XML and the full power of ruby to extract the relevant data any way you want. 

#### Finders / Modifiers
To aid in the method definitions a set of methods are provided to acomplish common tasks, some examples are:

* find_with
* find_all_with
* find_without
* find_all_without
* mapping
* add
* select

Overtime we can very easily expand this set of tools solve common problems across the different sources. 

## Testing
Since each adapater and each parser file are just ruby classes with very little dependencies it is very easy to test them with a predefined set of data.

## Installation

Add this line to your application's Gemfile:

    gem 'harvester_core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install harvester_core

## COPYRIGHT AND LICENSING  

### SUPPLEJACK CODE - GNU GENERAL PUBLIC LICENCE, VERSION 3  

Supplejack, a tool for aggregating, searching and sharing metadata records, is Crown copyright (C) 2014, New Zealand Government. 

Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. http://digitalnz.org/supplejack  

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

See the GNU General Public License for more details.  You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses / http://www.gnu.org/licenses/gpl-3.0.txt