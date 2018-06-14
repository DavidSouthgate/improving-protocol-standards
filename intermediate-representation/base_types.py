class Typedef:
	"""
	A class for modelling C-style typedefs
	"""
	
	def __init__(self, name, type_val):
		self.name = name
		self.type_val = type_val

class Choice:
	"""
	A class for modelling C-style enums
	"""
	
	def __init__(self):
		self.alternates = []
		
	def add_alternate(self, alternate):
		if alternate not in self.alternates:
			self.alternates.append(alternate)
			
class Array:
	"""
	A class for modelling arrays
	"""
	
	def __init__(self, typedef, width):
		self.typedef = typedef
		self.width = width
		
class Bit:
	"""
	A class for modelling an array of bits (potentially of length 1)
	"""
	
class Protocol:
	"""
	A class for modelling a protocol's header description
	"""
	
	def __init__(self):
		self.context = {}
		self.typedefs = {}
		self.structs = {}
		self.choices = {}
	
	def add_typedef(self, name, type_val):
		self.typedefs[name] = type_val
		
	def add_struct(self, name, struct):
		self.structs[name] = struct
		
	def add_choice(self, name, choice):
		self.choices[name] = choice
			
	
class Structure:
	"""
	A class for modelling C-style structs
	"""
	
	def __init__(self):
		self.elements = {}
		
	def add_element(self, elem_name, elem_type):
		self.elements[elem_name] = elem_type