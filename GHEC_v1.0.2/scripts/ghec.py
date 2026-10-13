import csc
import sys


def name():
    return "G-HUB Entangle for Cascadeur"


def description():
    return "Connects Cascadeur to G-HUB."


def run(scene):
    # Open the QML panel. Loading model.py also initializes the persistent backend.
    csc.view.PythonModelsManager.instance().show_qml_view("ghec")
    
    # Retrieve the persistent backend from the module cache and attach the scene.
    if "_ghec_persistent_backend" in sys.modules:
        sys.modules["_ghec_persistent_backend"].get_backend().set_scene(scene)