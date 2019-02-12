from . import Expression


class Other(Expression):
    tag_name: str = "expression_other"
    value: Expression = None

    def __init__(self, value: Expression = None):
        super().__init__()
        self.value = value

    def children_to_xml(self, element):
        element.append(self.value.to_xml())
