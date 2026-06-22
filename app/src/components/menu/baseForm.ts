// Editable fields of a base drink, shared by the add form (BaseSection) and the
// inline edit form (BaseEditForm). Mirrors the API's BaseAttrsInput.
export interface BaseEdit {
  name: string
  description?: string
  surchargeCents?: number
}
