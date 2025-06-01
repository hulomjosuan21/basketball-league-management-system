class ValueException(Exception):
    def __init__(self, message: str = None):
        self.message = message
        super().__init__(self.message if message is not None else "Value Error")