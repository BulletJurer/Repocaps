# autenticacion/admin.py
from django import forms
from django.contrib import admin
from django.contrib.auth.models import Group

from autenticacion.models import Empleado


# ==========================================================
# FILTRO LATERAL POR ADMIN WEB
# ==========================================================
class AdminWebFilter(admin.SimpleListFilter):
    """
    Filtro para ver sólo empleados que son / no son Admin Web.
    Basado en el grupo ADMIN_WEB del User asociado.
    """
    title = "Admin Web"
    parameter_name = "admin_web"

    def lookups(self, request, model_admin):
        return (
            ("si", "Sí"),
            ("no", "No"),
        )

    def queryset(self, request, queryset):
        value = self.value()
        if not value:
            return queryset

        admin_group, _ = Group.objects.get_or_create(name="ADMIN_WEB")
        admin_users = admin_group.user_set.values_list("username", flat=True)

        if value == "si":
            return queryset.filter(usuario__in=admin_users)
        if value == "no":
            return queryset.exclude(usuario__in=admin_users)
        return queryset


# ==========================================================
# FORM PERSONALIZADO PARA ADMIN
# ==========================================================
class EmpleadoAdminForm(forms.ModelForm):
    es_admin_web = forms.BooleanField(
        required=False,
        label="Admin Web",
        help_text="Puede acceder al panel de Administración Web.",
    )

    class Meta:
        model = Empleado
        fields = "__all__"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Marca el checkbox si el usuario YA está en el grupo ADMIN_WEB
        user = self.instance.linked_user if self.instance.pk else None
        if user and user.groups.filter(name="ADMIN_WEB").exists():
            self.fields["es_admin_web"].initial = True

    def save(self, commit=True):
        empleado = super().save(commit=commit)

        user = empleado.linked_user
        if not user:
            return empleado

        want_admin = self.cleaned_data.get("es_admin_web", False)
        admin_group, _ = Group.objects.get_or_create(name="ADMIN_WEB")

        if want_admin:
            user.groups.add(admin_group)
        else:
            user.groups.remove(admin_group)

        # staff si es SUPERVISOR o si es admin web
        is_supervisor = user.groups.filter(name="SUPERVISOR").exists()
        user.is_staff = is_supervisor or want_admin
        user.save()

        return empleado


# ==========================================================
# ADMIN DE EMPLEADO
# ==========================================================
@admin.register(Empleado)
class EmpleadoAdmin(admin.ModelAdmin):
    form = EmpleadoAdminForm

    # -------- LISTA --------
    list_display = (
        "rut",
        "usuario",
        "nombre",
        "cargo",
        "region",
        "recinto",
        "es_admin_web_flag",   # columna calculada
        "is_active",
        "is_staff",
        "is_superuser",
        "last_login",
    )

    list_editable = (
        "cargo",
        "region",
        "recinto",
        "is_active",
    )

    # -------- FILTROS --------
    list_filter = (
        "cargo",
        "region",
        "recinto",
        AdminWebFilter,        # filtro por Admin Web
        "is_active",
        "is_staff",
        "is_superuser",
    )

    # -------- BÚSQUEDA / ORDEN --------
    search_fields = (
        "rut",
        "usuario",
        "nombre",
        "cargo",
    )

    ordering = ("nombre",)

    # -------- FIELDSETS (FORM DETALLE) --------
    fieldsets = (
        ("Información Personal", {
            "fields": ("rut", "nombre", "usuario", "password", "cargo", "region", "recinto")
        }),
        ("Permisos", {
            "fields": ("es_admin_web", "is_active", "is_staff", "is_superuser"),
            "classes": ("collapse",),
        }),
        ("Sesión", {
            "fields": ("last_login",),
            "classes": ("collapse",),
        }),
    )

    readonly_fields = ("last_login",)

    # -------- COLUMNA CALCULADA --------
    def es_admin_web_flag(self, obj):
        """Muestra Sí/No en base al grupo ADMIN_WEB (propiedad is_admin_web)."""
        return obj.is_admin_web

    es_admin_web_flag.boolean = True
    es_admin_web_flag.short_description = "Admin Web"