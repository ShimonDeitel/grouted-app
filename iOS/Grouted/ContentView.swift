import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Job?

    var body: some View {
        NavigationStack {
            ZStack {
                GroutedTheme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Grouted")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore || purchases.isPro {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EntryFormView(itemToEdit: nil) { newItem in
                store.add(newItem)
            }
        }
        .sheet(item: $editingItem) { item in
            EntryFormView(itemToEdit: item) { updated in
                store.update(updated)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(GroutedTheme.accentBright)
            Text("No jobs yet")
                .font(GroutedTheme.headlineFont)
                .foregroundStyle(.white)
            Text("Tap + to log your first one.")
                .font(GroutedTheme.captionFont)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var list: some View {
        List {
            ForEach(store.items) { item in
                Button {
                    editingItem = item
                } label: {
                    row(for: item)
                }
                .accessibilityIdentifier("row_\(item.id.uuidString)")
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(for item: Job) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.room).font(GroutedTheme.headlineFont).foregroundStyle(GroutedTheme.ink)
            Text(item.groutColor).font(GroutedTheme.bodyFont).foregroundStyle(GroutedTheme.secondaryInk)
            Text(item.sealant).font(GroutedTheme.captionFont).foregroundStyle(GroutedTheme.secondaryInk)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.rating ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(GroutedTheme.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(GroutedTheme.cardBackground)
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: Store
    let itemToEdit: Job?
    let onSave: (Job) -> Void

    @State private var room: String
    @State private var groutColor: String
    @State private var sealant: String
    @State private var rating: Int
    @FocusState private var focusedField: Bool

    init(itemToEdit: Job?, onSave: @escaping (Job) -> Void) {
        self.itemToEdit = itemToEdit
        self.onSave = onSave
        _room = State(initialValue: itemToEdit?.room ?? "")
        _groutColor = State(initialValue: itemToEdit?.groutColor ?? "")
        _sealant = State(initialValue: itemToEdit?.sealant ?? "")
        _rating = State(initialValue: itemToEdit?.rating ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Room") {
                    TextField("Room", text: $\room)
                        .focused($focusedField)
                        .accessibilityIdentifier("field_room")
                }
                Section("Grout Color") {
                    TextField("Grout Color", text: $\groutColor)
                        .accessibilityIdentifier("field_groutColor")
                }
                Section("Sealant") {
                    TextField("Sealant", text: $\sealant, axis: .vertical)
                        .accessibilityIdentifier("field_sealant")
                }
                Section("Rating") {
                    Picker("Rating", selection: $rating) {
                        ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .navigationTitle(itemToEdit == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let base = itemToEdit ?? Job(room: room, groutColor: groutColor, sealant: sealant)
                        var updated = base
                        updated.room = room
                        updated.groutColor = groutColor
                        updated.sealant = sealant
                        updated.rating = rating
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(room.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}
