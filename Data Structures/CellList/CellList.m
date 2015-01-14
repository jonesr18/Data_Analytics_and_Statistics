%% Summary
%   Description

classdef CellList < handle
    
    properties (Access = private)
        data;
        size;
    end
    
    methods (Access = public)
        
        function self = CellList(varargin)
            % Check inputs
            if (nargin > 0)
                if (nargin > 1)
                    error('Too many input arguments')
                else
                    validateattributes(varargin{1}, {'numeric'}, {'positive'}, mfilename, 'capacity', 1);
                    capacity = varargin{1};
                end
            else
                capacity = 1000;
            end
            % Initialize cell structure which holds data
            self.data = cell(1, capacity);
            self.size = 0;
        end
        
        
        function matrix = toMat(self)
            % Returns a Matlab matrix version of the list.
            matrix = cell2mat(self.data);
        end
        
        
        function [] = add(self, item, varargin)
            % Adds the given item to the list.
            %   An index to insert at can be designated in the optional input.
            
            % Check inputs
            if (nargin > 2)
                if (nargin > 3)
                    error('Too many input arguments')
                else
                    validateattributes(varargin{1}, {'numeric'}, {'positive'}, mfilename, 'index', 2)
                    index = varargin{1};
                end
            else
                index = self.size + 1;
            end
            
            % Increase Capacity if necessary
            self.size = self.size + 1;
            if (self.size > numel(self.data))
                self.data = [self.data; cell(1, numel(self.data))];
            end
            self.checkIndex(index);
            
            % Handle special cases depending on where added (front, middle, back)
            if (index == 1)
                self.data = [{item}, self.data];
            elseif (index < self.size)
                self.data = [self.data{1:index - 1}; {item}; self.data{index:end}];
            else % index == self.size
                self.data{index} = item;
            end
        end
        
        
        function item = get(self, index)
            % Gets the item at the given index.
            
            % Check imput
            validateattributes(index, {'numeric'}, {'positive'}, mfilename, 'index', 1);
            index = round(index);
            self.checkIndex(index);
            
            item = self.data{index};
        end
        
        
        function set(self, index, item)
            % Sets the given index to the given item.
            
            % Check inputs
            validateattributes(index, {'numeric'}, {'positive'}, mfilename, 'index', 1);
            self.checkIndex(index);
            
            self.data{index} = item;
        end
        
    end
    
    
    methods (Access = private)
        
        function checkIndex(self, index)
            % Checks an index to ensure that it is valid.
            if (index > self.size)
                error(['Index too large, must be smaller than array size.\n' ...
                       'Size: %d\nIndex: %d\n'], self.size, index);
            end
        end
        
    end
end