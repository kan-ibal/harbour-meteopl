Name:       harbour-meteopl
Summary:    MeteoPL - Sailfish OS Meteo Client
Version:    1.3.1
Release:    0
Group:      Qt/Qt
License:    MIT
URL:        https://github.com/kan-ibal/harbour-meteopl
Source0:    %{name}-%{version}.tar.bz2
BuildArch:  noarch
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.4.0
Requires:   libsailfishapp-launcher
BuildRequires:   desktop-file-utils

%description
Native Jolla Sailfish OS client for reading and offline caching of old.meteo.pl weather meteograms.

%prep
%setup -q -n %{name}-%{version}

%build
# Pure QML, nothing to compile!

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}%{_datadir}/%{name}/qml
mkdir -p %{buildroot}%{_datadir}/%{name}/translations
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/86x86/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/108x108/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/128x128/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/172x172/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/256x256/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/512x512/apps


cp -r ./.sfdk/src/qml/* %{buildroot}%{_datadir}/%{name}/qml/
cp -r ./.sfdk/src/translations/* %{buildroot}%{_datadir}/%{name}/translations/ || cp -r translations/* %{buildroot}%{_datadir}/%{name}/translations/ || true
cp    ./.sfdk/src/%{name}.desktop %{buildroot}%{_datadir}/applications/ || cp %{name}.desktop %{buildroot}%{_datadir}/applications/ || true
cp -r ./.sfdk/src/icons %{buildroot}%{_datadir} || cp -r icons %{buildroot}%{_datadir} || true
cp    ./.sfdk/src/%{name}.png %{buildroot}%{_datadir}/icons/hicolor/512x512/apps || cp %{name}.png %{buildroot}%{_datadir}/icons/hicolor/512x512/apps || true


desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
