import importlib.util
import os
import sys

import csc
import shiboken6

from PySide6 import QtCore


_BACKEND_MODULE_NAME = "_ghec_persistent_backend"


def _load_backend_module():
    if _BACKEND_MODULE_NAME in sys.modules:
        return sys.modules[_BACKEND_MODULE_NAME]

    module_dir = os.path.dirname(__file__)
    backend_candidates = (
        os.path.join(module_dir, "backend.pyc"),
        os.path.join(module_dir, "backend.py"),
    )

    backend_path = next(
        (path for path in backend_candidates if os.path.isfile(path)),
        None
    )

    if backend_path is None:
        raise RuntimeError(
            "GHEC backend was not found. Expected backend.pyc or backend.py."
        )

    spec = importlib.util.spec_from_file_location(
        _BACKEND_MODULE_NAME,
        backend_path
    )

    if spec is None or spec.loader is None:
        raise RuntimeError(
            "Could not load GHEC backend."
        )

    module = importlib.util.module_from_spec(
        spec
    )

    sys.modules[
        _BACKEND_MODULE_NAME
    ] = module

    spec.loader.exec_module(
        module
    )

    return module


_backend_module = _load_backend_module()


class GHECDialogModel(QtCore.QObject):
    status_changed = QtCore.Signal()
    connection_state_changed = QtCore.Signal()
    endpoint_changed = QtCore.Signal()
    timeline_sync_changed = QtCore.Signal()
    slot_configuration_changed = QtCore.Signal()
    network_settings_changed = QtCore.Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._backend = (
            _backend_module.get_backend()
        )

        self._backend.status_changed.connect(
            self._on_status_changed
        )

        self._backend.connection_state_changed.connect(
            self._on_connection_state_changed
        )

        self._backend.endpoint_changed.connect(
            self._on_endpoint_changed
        )

        self._backend.timeline_sync_changed.connect(
            self._on_timeline_sync_changed
        )

        self._backend.slot_configuration_changed.connect(
            self._on_slot_configuration_changed
        )

        self._backend.network_settings_changed.connect(
            self._on_network_settings_changed
        )


    # ---------------------------------------------------------
    # QML Properties
    # ---------------------------------------------------------

    @QtCore.Property(
        str,
        notify=status_changed,
        final=True
    )
    def status_text(self):
        return self._backend.status_text

    @QtCore.Property(
        str,
        notify=status_changed,
        final=True
    )
    def status_code(self):
        return self._backend.status_code

    @QtCore.Property(
        bool,
        notify=connection_state_changed,
        final=True
    )
    def connected(self):
        return self._backend.connected

    @QtCore.Property(
        int,
        notify=endpoint_changed,
        final=True
    )
    def endpoint_id(self):
        return self._backend.endpoint_id

    @QtCore.Property(
        bool,
        notify=timeline_sync_changed,
        final=True
    )
    def timeline_sync_enabled(self):
        return self._backend.timeline_sync_enabled

    @QtCore.Property(
        bool,
        notify=status_changed,
        final=True
    )
    def slot_configuration_editable(self):
        return self._backend.slot_configuration_editable

    @QtCore.Property(
        bool,
        notify=slot_configuration_changed,
        final=True
    )
    def slot_configuration_dirty(self):
        return self._backend.slot_configuration_dirty

    @QtCore.Property(
        int,
        notify=network_settings_changed,
        final=True
    )
    def control_port(self):
        return self._backend.control_port

    @QtCore.Property(
        bool,
        notify=status_changed,
        final=True
    )
    def control_port_editable(self):
        return self._backend.control_port_editable

    @QtCore.Property(
        "QStringList",
        notify=slot_configuration_changed,
        final=True
    )
    def character_candidate_labels(self):
        return self._backend.get_character_candidate_labels()

    @QtCore.Property(
        int,
        notify=slot_configuration_changed,
        final=True
    )
    def character1_candidate_index(self):
        return self._backend.get_character_slot_candidate_index(0)

    @QtCore.Property(
        int,
        notify=slot_configuration_changed,
        final=True
    )
    def character2_candidate_index(self):
        return self._backend.get_character_slot_candidate_index(1)

    @QtCore.Property(
        int,
        notify=slot_configuration_changed,
        final=True
    )
    def character3_candidate_index(self):
        return self._backend.get_character_slot_candidate_index(2)

    @QtCore.Property(
        int,
        notify=slot_configuration_changed,
        final=True
    )
    def character4_candidate_index(self):
        return self._backend.get_character_slot_candidate_index(3)

    @QtCore.Property(
        int,
        notify=slot_configuration_changed,
        final=True
    )
    def character5_candidate_index(self):
        return self._backend.get_character_slot_candidate_index(4)

    @QtCore.Property(
        bool,
        notify=slot_configuration_changed,
        final=True
    )
    def character1_enabled(self):
        return self._backend.is_character_slot_enabled(0)

    @QtCore.Property(
        bool,
        notify=slot_configuration_changed,
        final=True
    )
    def character2_enabled(self):
        return self._backend.is_character_slot_enabled(1)

    @QtCore.Property(
        bool,
        notify=slot_configuration_changed,
        final=True
    )
    def character3_enabled(self):
        return self._backend.is_character_slot_enabled(2)

    @QtCore.Property(
        bool,
        notify=slot_configuration_changed,
        final=True
    )
    def character4_enabled(self):
        return self._backend.is_character_slot_enabled(3)

    @QtCore.Property(
        bool,
        notify=slot_configuration_changed,
        final=True
    )
    def character5_enabled(self):
        return self._backend.is_character_slot_enabled(4)

    @QtCore.Property(
        str,
        notify=slot_configuration_changed,
        final=True
    )
    def character1_assignment_text(self):
        return self._backend.get_character_slot_assignment_text(0)

    @QtCore.Property(
        str,
        notify=slot_configuration_changed,
        final=True
    )
    def character2_assignment_text(self):
        return self._backend.get_character_slot_assignment_text(1)

    @QtCore.Property(
        str,
        notify=slot_configuration_changed,
        final=True
    )
    def character3_assignment_text(self):
        return self._backend.get_character_slot_assignment_text(2)

    @QtCore.Property(
        str,
        notify=slot_configuration_changed,
        final=True
    )
    def character4_assignment_text(self):
        return self._backend.get_character_slot_assignment_text(3)

    @QtCore.Property(
        str,
        notify=slot_configuration_changed,
        final=True
    )
    def character5_assignment_text(self):
        return self._backend.get_character_slot_assignment_text(4)

    # ---------------------------------------------------------
    # QML Operations
    # ---------------------------------------------------------

    @QtCore.Slot()
    def toggle_connection(self):
        self._backend.toggle_connection()

    @QtCore.Slot(int, result=bool)
    def set_control_port(self, value):
        return self._backend.set_control_port(value)

    @QtCore.Slot(bool)
    def set_timeline_sync_enabled(self, enabled):
        self._backend.set_timeline_sync_enabled(enabled)

    @QtCore.Slot(bool)
    def set_character1_enabled(self, enabled):
        self._backend.set_character_slot_enabled(0, enabled)

    @QtCore.Slot(bool)
    def set_character2_enabled(self, enabled):
        self._backend.set_character_slot_enabled(1, enabled)

    @QtCore.Slot(bool)
    def set_character3_enabled(self, enabled):
        self._backend.set_character_slot_enabled(2, enabled)

    @QtCore.Slot(bool)
    def set_character4_enabled(self, enabled):
        self._backend.set_character_slot_enabled(3, enabled)

    @QtCore.Slot(bool)
    def set_character5_enabled(self, enabled):
        self._backend.set_character_slot_enabled(4, enabled)

    @QtCore.Slot(result=bool)
    def save_character_slots(self):
        return self._backend.save_character_slot_configuration()

    @QtCore.Slot(result=bool)
    def refresh_character_candidates(self):
        return self._backend.refresh_character_candidates()

    @QtCore.Slot(int, int, result=bool)
    def set_character_candidate(self, slot_index, candidate_index):
        return self._backend.set_character_slot_candidate(
            slot_index, candidate_index)

    @QtCore.Slot(int, result=bool)
    def clear_character_assignment(self, slot_index):
        return self._backend.clear_character_slot_assignment(slot_index)

    # ---------------------------------------------------------
    # Backend -> QML
    # ---------------------------------------------------------

    @QtCore.Slot()
    def _on_status_changed(self):
        self.status_changed.emit()

    @QtCore.Slot()
    def _on_connection_state_changed(self):
        self.connection_state_changed.emit()

    @QtCore.Slot()
    def _on_endpoint_changed(self):
        self.endpoint_changed.emit()

    @QtCore.Slot()
    def _on_timeline_sync_changed(self):
        self.timeline_sync_changed.emit()

    @QtCore.Slot()
    def _on_slot_configuration_changed(self):
        self.slot_configuration_changed.emit()

    @QtCore.Slot()
    def _on_network_settings_changed(self):
        self.network_settings_changed.emit()


# -------------------------------------------------------------------------
# Cascadeur PythonModelsManager entry points
# -------------------------------------------------------------------------

def qml_view_name():
    return "view"


def create_model():
    model = GHECDialogModel()

    ptr = shiboken6.getCppPointer(
        model
    )

    if isinstance(ptr, tuple):
        ptr = ptr[0]

    return model, ptr


def show_qml_view(model, name):
    csc.view.PythonModelsManager.instance().show_dialog(
        "G-HUB Entangle for Cascadeur",
        name
    )