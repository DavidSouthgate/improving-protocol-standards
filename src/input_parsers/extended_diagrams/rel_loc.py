class RelLoc:
    field_this: str = None
    value: int = None
    field_new: str = None
    rel_loc: int = None
    field_loc: str = None
    section_number: str = None

    def __init__(self, field_this: str = None, value: int = None, field_new: str = None, rel_loc: int = None,
                 field_loc: str = None, section_number: str = None) -> None:
        self.field_this = field_this
        self.value = value
        self.field_new = field_new
        self.rel_loc = rel_loc
        self.field_loc = field_loc
        self.section_number = section_number