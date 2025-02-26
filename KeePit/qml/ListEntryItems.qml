/*
* This file is part of KeePit
*
* Copyright (C) 2016 Dan Beavon
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import KeePass3 1.0

Page {

    property alias actTheme: themeAction
    property alias pageHeaderTitle: pageHeader.title
    
    property var searching: false

    function setPageHeader(selectedEntry) {
        console.debug("ListEntryItems: " + selectedEntry.title)
        pageHeader.title = !selectedEntry.title 
            ? i18n.tr(appTitle)
            : selectedEntry.title
    }   

    function setPreviousEntry(selectedEntry) {
        // A variable property on MainView (Main.qml)
        previousEntry = {
            entryType : database.selectedEntry.entryType,
            UUID : database.selectedEntry.uuid,
            title: database.selectedEntry.title,
            searching: searching
        }
    }

    function resetSearchingState() {
        searching = false
    }

    function handlePageStack(selectedEntry) {
        // See PageStack.onDepthChanged for how the pageStack and entry model are kept in synch
        if(selectedEntry.entryType === 2) { // is a password entry so push password page            
            pageStack.push(entry);
        } else if(selectedEntry.entryType === 1) { // is a further branch push another level
            pageStack.push(listEntryItems);
        }   
    }

    /**
      * Handles the MouseArea.onClicked event of the entryDelegate
      */
    function onSelected(index, model) {
        // A variable property on Database (Main.qml)
        database.selectedEntry = model;

        setPageHeader(database.selectedEntry)
        setPreviousEntry(database.selectedEntry)
        resetSearchingState()
        handlePageStack(database.selectedEntry)

        listView.currentIndex = index;        
    }

    function getIconName(model) {
        if(model.entryType === 2) {
            return "note";
        } else {
            return "document-open";
        }
    }

    // Could be the name of the group
    header: PageHeader {
      id: pageHeader
      title: i18n.tr(appTitle)
      trailingActionBar.actions: [
          Action {
            iconName: "switch"
            text: i18n.tr("Sort")
            onTriggered: {
                if(sortedEntries.sort.order === Qt.AscendingOrder) {
                    sortedEntries.sort.order = Qt.DescendingOrder
                } else {
                    sortedEntries.sort.order = Qt.AscendingOrder
                }
            }
          },
          Action {
            id: themeAction
            iconName: ""
            text: i18n.tr("Swap")            
            onTriggered: {
                switchTheme()
                themeAction.iconName = getTheme()
                saveTheme()
            }                      
          },
        /*Action {
            text: i18n.tr("Settings")
            iconName: "settings"
            onTriggered: PopupUtils.open(settingsDisabledComponent)
        },*/
        Action {
          iconName: "home"
          text: i18n.tr("Home")
          onTriggered: {
              goHome()
          }
        },
        Action {
          iconName: "system-log-out"
          text: i18n.tr("Logout")
          onTriggered: {
              reset();
          }
        }
      ]
    }

    Column {
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
            topMargin: pageHeader.height + units.gu(2)
        }

        Component {
            id: entryDelegate
            ListItem {
                width: listView.width
                height: units.gu(5)
                GridLayout {
                  anchors.verticalCenter: parent.verticalCenter
                  columns: 2
                  Icon {
                      width: 40
                      height: 40
                      name: getIconName(model)
                      color: theme.palette.normal.baseText
                  }
                  Text {
                    text: title
                    color: theme.palette.normal.baseText
                  }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: onSelected(index, model)
                }
            }            
        }

        SortFilterModel {
            id: sortedEntries
            model: passwordEntryModel
            sort.property: "title"
            sort.order: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
        }

        TextField {
            id: search
            width: parent.width
            placeholderText: i18n.tr("Enter a search term")
            hasClearButton: true
            onAccepted: {
                if(search.text == "") {
                    goHome()
                } else {
                    database.search(search.text)
                    searching = true
                }
            }            
        }

        UbuntuListView {            
            id: listView
            height: parent.height
            width: parent.width
            spacing: 5
            model: sortedEntries
            delegate: entryDelegate
            focus: true
        }
    }
}
